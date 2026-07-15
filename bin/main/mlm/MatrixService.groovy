package mlm

import org.springframework.stereotype.Service

/**
 * Core Matrix Plan placement service for MLM system.
 * 
 * Matrix Plan Logic:
 * - Members are placed in a grid (width x height)
 * - Each member has a left leg and right leg
 * - New members are placed in the first available position
 * - Placement follows: left leg first, then right leg
 * - When a leg is full, placement moves to the next level
 */
@Service
class MatrixService {

    static final String DIRECTION_LEFT = 'LEFT'
    static final String DIRECTION_RIGHT = 'RIGHT'
    static final String PLACEMENT_ROOT = 'ROOT'
    
    /**
     * Result object for placement operation
     */
    static class PlacementResult {
        boolean success
        Member placedMember
        Member parent
        Member sponsor
        String placementPosition
        String direction
        String message
        Integer depth
        Map<String, Object> details
        
        PlacementResult(boolean success, String message) {
            this.success = success
            this.message = message
            this.details = [:]
        }
        
        static PlacementResult success(
            Member placedMember,
            Member parent,
            Member sponsor,
            String placementPosition,
            String direction,
            Integer depth = 0) {
            
            def result = new PlacementResult(true, "Successfully placed ${placedMember?.userId} at ${placementPosition}")
            result.placedMember = placedMember
            result.parent = parent
            result.sponsor = sponsor
            result.placementPosition = placementPosition
            result.direction = direction
            result.depth = depth
            result.details = [
                parentLeftCount: parent?.leftLegCount,
                parentRightCount: parent?.rightLegCount
            ]
            return result
        }
        
        static PlacementResult failure(String message) {
            return new PlacementResult(false, message)
        }
    }
    
    /**
     * Main placement method - places a new member in the matrix
     * @param newMember The member to place
     * @param sponsorId The sponsor's user ID (can be null for root member)
     * @return PlacementResult with placement details
     */
    PlacementResult placeMember(Member newMember, String sponsorId) {
        // Validate member
        if (!newMember?.save(failOnError: true, flush: true)) {
            return PlacementResult.failure("Failed to create member record")
        }
        
        // If no sponsor, this is a root member
        if (!sponsorId || sponsorId.isEmpty()) {
            return placeRootMember(newMember)
        }
        
        // Find sponsor
        Member sponsor = Member.findByUserId(sponsorId)
        if (!sponsor) {
            return PlacementResult.failure("Sponsor with ID '${sponsorId}' not found")
        }
        
        if (sponsor.status != 'ACTIVE') {
            return PlacementResult.failure("Sponsor '${sponsorId}' is not active")
        }
        
        // Perform placement starting from sponsor
        return findAndPlaceInTree(newMember, sponsor, sponsor, 0)
    }
    
    /**
     * Place a root member (no sponsor)
     */
    private PlacementResult placeRootMember(Member member) {
        member.parentId = null
        member.sponsorId = null
        member.position = 0
        member.placementPosition = PLACEMENT_ROOT
        member.leftLegCount = 0
        member.rightLegCount = 0
        member.level = 0
        member.status = 'ACTIVE'
        member.save(flush: true)
        
        // Log transaction
        logPlacement(member, null, null, PLACEMENT_ROOT, DIRECTION_LEFT, 0)
        
        return PlacementResult.success(
            member, null, null, PLACEMENT_ROOT, DIRECTION_LEFT, 0
        )
    }
    
    /**
     * Recursively find the best position in the sponsorship tree
     * Priority: Left leg first, then right leg
     * When both legs are balanced and have space, prefer left
     */
    private PlacementResult findAndPlaceInTree(
        Member newMember,
        Member sponsor,
        Member current,
        Integer depth) {
        
        // Get matrix configuration
        def config = getMatrixConfig(current)
        Integer width = config.matrixWidth
        Integer height = config.matrixHeight
        Integer slotsPerLeg = (width - 1) * height / 2
        
        // Check if current member can accept direct placement
        if (canPlaceDirectly(current, config)) {
            return placeDirectly(newMember, current, sponsor, DIRECTION_LEFT, depth, config)
        }
        
        // Try placing in left subtree first
        def leftChild = findFirstAvailablePosition(current, DIRECTION_LEFT, depth + 1, config)
        if (leftChild?.success) {
            return leftChild
        }
        
        // Then try right subtree
        def rightChild = findFirstAvailablePosition(current, DIRECTION_RIGHT, depth + 1, config)
        if (rightChild?.success) {
            return rightChild
        }
        
        return PlacementResult.failure("No available position found in the matrix tree")
    }
    
    /**
     * Find first available position recursively in a direction
     */
    private PlacementResult findFirstAvailablePosition(
        Member current,
        String direction,
        Integer depth,
        def config) {
        
        // Get children in the specified direction
        def children = direction == DIRECTION_LEFT ? current.leftChildren : current.rightChildren
        
        // Try to place in each child
        for (child in children) {
            if (canPlaceDirectly(child, config)) {
                return placeDirectly(null, child, current.sponsor, direction, depth, config).tap {
                    // We need to find the actual new member - this is handled differently
                }
            }
            // Recurse deeper
            def result = findFirstAvailablePosition(child, direction, depth + 1, config)
            if (result?.success) {
                return result
            }
        }
        
        return null
    }
    
    /**
     * Check if a member can accept direct placement
     */
    private boolean canPlaceDirectly(Member member, def config) {
        if (!member || member.status != 'ACTIVE') {
            return false
        }
        
        Integer maxSlots = (config.matrixWidth - 1) * config.matrixHeight
        Integer currentTotal = (member.leftLegCount ?: 0) + (member.rightLegCount ?: 0)
        
        // Member has space if current count < max slots
        return currentTotal < maxSlots
    }
    
    /**
     * Place a member directly under a parent
     */
    private PlacementResult placeDirectly(
        Member newMember,
        Member parent,
        Member sponsor,
        String preferredDirection,
        Integer depth,
        def config) {
        
        // Determine placement direction based on leg balance
        String direction = determineDirection(parent, config)
        String position = generatePosition(parent, direction, depth)
        
        // Update parent's leg count
        if (direction == DIRECTION_LEFT) {
            parent.leftLegCount = (parent.leftLegCount ?: 0) + 1
        } else {
            parent.rightLegCount = (parent.rightLegCount ?: 0) + 1
        }
        parent.save(flush: true)
        
        // Update new member's fields
        if (newMember) {
            newMember.parentId = parent.id
            newMember.sponsorId = sponsor?.userId
            newMember.position = parent.id.intValue()
            newMember.placementPosition = position
            newMember.direction = direction
            newMember.level = depth
            newMember.status = 'ACTIVE'
            newMember.matrixWidth = config.matrixWidth
            newMember.matrixHeight = config.matrixHeight
            newMember.leftLegCount = 0
            newMember.rightLegCount = 0
            newMember.save(flush: true)
        }
        
        // Log the transaction
        if (newMember) {
            logPlacement(newMember, sponsor, parent, position, direction, depth)
        }
        
        return PlacementResult.success(
            newMember, parent, sponsor, position, direction, depth
        )
    }
    
    /**
     * Determine which leg to place in based on balance
     * Prefers the leg with fewer members
     */
    private String determineDirection(Member parent, def config) {
        Integer leftCount = parent.leftLegCount ?: 0
        Integer rightCount = parent.rightLegCount ?: 0
        Integer maxSlots = (config.matrixWidth - 1) * config.matrixHeight
        
        // If left leg is full, must use right
        if (leftCount >= maxSlots) {
            return DIRECTION_RIGHT
        }
        // If right leg is full, must use left
        if (rightCount >= maxSlots) {
            return DIRECTION_LEFT
        }
        // Prefer the leg with fewer members (balance)
        if (leftCount <= rightCount) {
            return DIRECTION_LEFT
        }
        return DIRECTION_RIGHT
    }
    
    /**
     * Generate position string based on direction and depth
     */
    private String generatePosition(Member parent, String direction, Integer depth) {
        String prefix = direction == DIRECTION_LEFT ? 'L' : 'R'
        return "${prefix}${depth ?: 0}"
    }
    
    /**
     * Get matrix configuration for a member
     */
    def getMatrixConfig(Member member) {
        def config = MatrixConfig.findWhere(status: 'ACTIVE')
        if (!config) {
            config = MatrixConfig.getDefaultConfig()
        }
        return config
    }
    
    /**
     * Log a placement transaction
     */
    private void logPlacement(
        Member member,
        Member sponsor,
        Member parent,
        String position,
        String direction,
        Integer depth) {
        
        def config = getMatrixConfig(member)
        
        def transaction = new PlacementTransaction(
            member: member,
            sponsor: sponsor,
            parent: parent,
            placementPosition: position,
            direction: direction,
            parentLeftCountBefore: parent?.leftLegCount,
            parentRightCountBefore: parent?.rightLegCount,
            matrixWidth: config?.matrixWidth?.toString(),
            matrixHeight: config?.matrixHeight?.toString(),
            resultMessage: "Placed at ${position}",
            depth: depth
        )
        transaction.save(flush: true)
    }
    
    /**
     * Get the complete genealogy tree for a member
     */
    Map<String, Object> getGenealogyTree(Member member, Integer maxDepth = 10) {
        def tree = [
            member: member,
            leftChildren: [],
            rightChildren: [],
            totalDownlines: member.totalDownlines
        ]
        
        if (maxDepth > 0) {
            for (child in member.leftChildren) {
                tree.leftChildren << getGenealogyTree(child, maxDepth - 1)
            }
            for (child in member.rightChildren) {
                tree.rightChildren << getGenealogyTree(child, maxDepth - 1)
            }
        }
        
        return tree
    }
    
    /**
     * Get matrix visualization data for a member
     */
    Map<String, Object> getMatrixVisualization(Member member) {
        def config = getMatrixConfig(member)
        Integer width = config.matrixWidth
        Integer height = config.matrixHeight
        
        // Build grid
        String[][] grid = new String[height][width]
        for (int i = 0; i < height; i++) {
            for (int j = 0; j < width; j++) {
                grid[i][j] = ''
            }
        }
        
        // Place root member
        grid[0][0] = member.userId
        
        // Fill children positions
        def allDownlines = getAllDownlinesInOrder(member)
        int slotIndex = 0
        for (String userId in allDownlines) {
            int row = (slotIndex / (width - 1)) as int + 1
            int col = (slotIndex % (width - 1)) + 1
            if (row < height && col < width) {
                grid[row][col] = userId
            }
            slotIndex++
        }
        
        return [
            member: member,
            config: config,
            grid: grid,
            leftCount: member.leftLegCount,
            rightCount: member.rightLegCount,
            leftCapacity: ((width - 1) * height / 2),
            rightCapacity: ((width - 1) * height / 2),
            totalDownlines: member.totalDownlines
        ]
    }
    
    /**
     * Get all downlines ordered by placement
     */
    private List<String> getAllDownlinesInOrder(Member member) {
        List<String> result = []
        def queue = [member]
        
        while (!queue.isEmpty() && result.size() < 100) {
            def current = queue.shift()
            for (child in (current.leftChildren + current.rightChildren)) {
                if (child) {
                    result.add(child.userId)
                    queue.add(child)
                }
            }
        }
        
        return result
    }
    
    /**
     * Calculate commission eligibility for a member
     */
    Map<String, Object> calculateCommissionEligibility(Member member) {
        def config = getMatrixConfig(member)
        Integer leftCount = member.leftLegCount ?: 0
        Integer rightCount = member.rightLegCount ?: 0
        Integer capacity = (config.matrixWidth - 1) * config.matrixHeight / 2
        
        boolean leftFull = leftCount >= capacity
        boolean rightFull = rightCount >= capacity
        boolean bothFull = leftFull && rightFull
        
        return [
            member: member,
            leftCount: leftCount,
            rightCount: rightCount,
            leftCapacity: capacity,
            rightCapacity: capacity,
            leftFull: leftFull,
            rightFull: rightFull,
            bothFull: bothFull,
            leftCommissionRate: config.leftCommissionRate,
            rightCommissionRate: config.rightCommissionRate,
            matchingBonusRate: config.matchingBonusRate,
            poolBonusRate: config.poolBonusRate
        ]
    }
    
    /**
     * Search for members by various criteria
     */
    List<Member> searchMembers(Map<String, Object> criteria) {
        def queryParams = [:]
        
        if (criteria?.userId) {
            queryParams.userIdLike = "%${criteria.userId}%"
        }
        if (criteria?.userName) {
            queryParams.userNameLike = "%${criteria.userName}%"
        }
        if (criteria?.fullName) {
            queryParams.fullNameLike = "%${criteria.fullName}%"
        }
        if (criteria?.status) {
            queryParams.status = criteria.status
        }
        if (criteria?.sponsorId) {
            queryParams.sponsorId = criteria.sponsorId
        }
        if (criteria?.minLevel != null) {
            queryParams.levelGte = criteria.minLevel
        }
        if (criteria?.maxLevel != null) {
            queryParams.levelLte = criteria.maxLevel
        }
        
        return Member.findAllByOrderByJoinDateDesc(queryParams)
    }
    
    /**
     * Activate a member (change status from PENDING to ACTIVE)
     */
    PlacementResult activateMember(String userId) {
        Member member = Member.findByUserId(userId)
        if (!member) {
            return PlacementResult.failure("Member '${userId}' not found")
        }
        
        if (member.status == 'ACTIVE') {
            return PlacementResult.failure("Member '${userId}' is already active")
        }
        
        member.status = 'ACTIVE'
        member.save(flush: true)
        
        return PlacementResult.success(
            member, null, null, 'N/A', 'ACTIVATED', 0
        ).tap {
            it.message = "Member '${userId}' activated successfully"
        }
    }
    
    /**
     * Deactivate a member
     */
    PlacementResult deactivateMember(String userId) {
        Member member = Member.findByUserId(userId)
        if (!member) {
            return PlacementResult.failure("Member '${userId}' not found")
        }
        
        if (member.status != 'ACTIVE') {
            return PlacementResult.failure("Member '${userId}' is not active")
        }
        
        member.status = 'INACTIVE'
        member.save(flush: true)
        
        return PlacementResult.success(
            member, null, null, 'N/A', 'DEACTIVATED', 0
        ).tap {
            it.message = "Member '${userId}' deactivated successfully"
        }
    }
    
    /**
     * Get placement history for a member
     */
    List<PlacementTransaction> getPlacementHistory(Member member) {
        return PlacementTransaction.findAllByMemberOrderByPlacementDateDesc(member)
    }
    
    /**
     * Get statistics for the MLM organization
     */
    Map<String, Object> getOrganizationStatistics() {
        def totalMembers = Member.count()
        def activeMembers = Member.countByStatus('ACTIVE')
        def pendingMembers = Member.countByStatus('PENDING')
        
        def rootMembers = Member.countByParentIdIsNull()
        def totalTransactions = PlacementTransaction.count()
        
        // Get deepest level
        def maxLevelResult = Member.createCriteria().get {
            projections {
                max('level')
            }
        }
        
        return [
            totalMembers: totalMembers,
            activeMembers: activeMembers,
            pendingMembers: pendingMembers,
            inactiveMembers: Member.countByStatus('INACTIVE'),
            rootMembers: rootMembers,
            totalTransactions: totalTransactions,
            maxLevel: maxLevelResult ?: 0,
            growthRate: calculateGrowthRate()
        ]
    }
    
    /**
     * Calculate monthly growth rate
     */
    private BigDecimal calculateGrowthRate() {
        def now = new Date()
        def oneMonthAgo = new Date(now.getTime() - 30L * 24 * 60 * 60 * 1000)
        
        def recentRegistrations = Member.countByJoinDateGreaterThanEqual(oneMonthAgo)
        def totalMembers = Member.count()
        
        if (totalMembers == 0) {
            return new BigDecimal(0)
        }
        
        return new BigDecimal(recentRegistrations.toString()).divide(
            new BigDecimal(totalMembers.toString()), 4, BigDecimal.ROUND_HALF_UP
        ).multiply(new BigDecimal(100))
    }
}