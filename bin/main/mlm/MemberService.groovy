package mlm

class MemberService {

    /**
     * List members with pagination
     */
    Map listMembers(params) {
        int max = Math.min(params.max ? params.int('max') : 10, 100)
        int offset = params.offset ? params.int('offset') : 0
        String sortBy = params.sortBy ?: 'joinDate'
        String sortOrder = params.sortOrder ?: 'desc'
        
        def criteria = Member.createCriteria()
        def results = criteria.list {
            if (params?.status) {
                eq('status', params.status)
            }
            if (params?.search) {
                or {
                    ilike('userId', "%${params.search}%")
                    ilike('userName', "%${params.search}%")
                    ilike('fullName', "%${params.search}%")
                    ilike('email', "%${params.search}%")
                }
            }
            if (params?.sponsorId) {
                eq('sponsorId', params.sponsorId)
            }
            orderBy(sortBy, sortOrder)
            maxResults(max)
            firstResult(offset)
        }
        
        def total = Member.count()
        
        return [
            members: results,
            total: total,
            pageSize: max,
            currentPage: (offset / max) + 1,
            totalPages: (int) Math.ceil((double) total / max)
        ]
    }
    
    /**
     * Get member by ID
     */
    Member getMemberById(Long id) {
        return Member.get(id)
    }
    
    /**
     * Get member by userId
     */
    Member getMemberByUserId(String userId) {
        return Member.findByUserId(userId)
    }
    
    /**
     * Get member statistics
     */
    Map getMemberStats() {
        return [
            totalMembers: Member.count(),
            activeMembers: Member.countByStatus('ACTIVE'),
            pendingMembers: Member.countByStatus('PENDING'),
            inactiveMembers: Member.countByStatus('INACTIVE'),
            bannedMembers: Member.countByStatus('BANNED'),
            rootMembers: Member.countByParentIdIsNull()
        ]
    }
    
    /**
     * Get downline count for a member (direct only)
     */
    Integer getDirectDownlineCount(Long memberId) {
        return Member.countByParentId(memberId)
    }
    
    /**
     * Get total downline count for a member (recursive)
     */
    Integer getTotalDownlineCount(Long memberId) {
        Member member = Member.get(memberId)
        return member?.totalDownlines ?: 0
    }
    
    /**
     * Get downlines for a member
     */
    List<Member> getDownlines(Long memberId, Integer maxDepth = null) {
        Member member = Member.get(memberId)
        if (!member) return []
        
        def downlines = Member.findAllByParentId(memberId)
        
        if (maxDepth != null && maxDepth > 0) {
            def allDownlines = []
            def queue = [member]
            def depthMap = [(member.id): 0]
            
            while (!queue.isEmpty()) {
                def current = queue.shift()
                def currentDepth = depthMap[current.id]
                
                if (currentDepth >= maxDepth) continue
                
                def children = Member.findAllByParentId(current.id)
                for (child in children) {
                    allDownlines.add(child)
                    queue.add(child)
                    depthMap[child.id] = currentDepth + 1
                }
            }
            
            return allDownlines
        }
        
        return downlines
    }
    
    /**
     * Get upline/sponsor chain for a member
     */
    List<Member> getUplineChain(String userId) {
        List<Member> chain = []
        Member current = Member.findByUserId(userId)
        
        while (current?.sponsorId) {
            Member sponsor = Member.findByUserId(current.sponsorId)
            if (!sponsor) break
            chain.add(sponsor)
            current = sponsor
        }
        
        return chain
    }
    
    /**
     * Check if userId is available
     */
    boolean isUserIdAvailable(String userId) {
        if (!userId || userId.isEmpty()) return false
        return Member.countByUserId(userId) == 0
    }
    
    /**
     * Check if email is available
     */
    boolean isEmailAvailable(String email) {
        if (!email || email.isEmpty()) return false
        return Member.countByEmail(email) == 0
    }
    
    /**
     * Bulk import members from data
     */
    Map bulkImport(List<Map> memberDataList, String defaultSponsorId = null) {
        int success = 0
        int failed = 0
        List<String> errors = []
        
        for (int i = 0; i < memberDataList.size(); i++) {
            def data = memberDataList[i]
            try {
                def member = new Member([
                    userId: data.userId,
                    userName: data.userName,
                    fullName: data.fullName,
                    email: data.email,
                    phoneNumber: data.phoneNumber,
                    password: data.password ?: 'password123',
                    sponsorId: data.sponsorId ?: defaultSponsorId
                ])
                
                def result = grailsApplication.getApplicationContext().getBean(MatrixService)
                    .placeMember(member, data.sponsorId ?: defaultSponsorId)
                
                if (result.success) {
                    success++
                } else {
                    failed++
                    errors.add("Row ${i + 1}: ${result.message}")
                }
            } catch (Exception e) {
                failed++
                errors.add("Row ${i + 1}: ${e.message}")
            }
        }
        
        return [
            success: success,
            failed: failed,
            total: memberDataList.size(),
            errors: errors
        ]
    }
    
    /**
     * Get members by sponsor
     */
    List<Member> getMembersBySponsor(String sponsorId) {
        return Member.findAllBySponsorId(sponsorId).sort { a, b -> a.joinDate <=> b.joinDate }
    }
    
    /**
     * Get members by level
     */
    List<Member> getMembersByLevel(Integer level) {
        return Member.findAllByLevel(level).sort { a, b -> a.joinDate <=> b.joinDate }
    }
    
    /**
     * Search members with advanced criteria
     */
    List<Member> advancedSearch(Map criteria) {
        def hql = "FROM Member WHERE 1=1"
        def params = [:]
        
        if (criteria?.userId) {
            hql += " AND userId LIKE :userId"
            params.userId = "%${criteria.userId}%"
        }
        if (criteria?.userName) {
            hql += " AND userName LIKE :userName"
            params.userName = "%${criteria.userName}%"
        }
        if (criteria?.fullName) {
            hql += " AND fullName LIKE :fullName"
            params.fullName = "%${criteria.fullName}%"
        }
        if (criteria?.email) {
            hql += " AND email LIKE :email"
            params.email = "%${criteria.email}%"
        }
        if (criteria?.status) {
            hql += " AND status = :status"
            params.status = criteria.status
        }
        if (criteria?.sponsorId) {
            hql += " AND sponsorId = :sponsorId"
            params.sponsorId = criteria.sponsorId
        }
        if (criteria?.minLevel != null) {
            hql += " AND level >= :minLevel"
            params.minLevel = criteria.minLevel
        }
        if (criteria?.maxLevel != null) {
            hql += " AND level <= :maxLevel"
            params.maxLevel = criteria.maxLevel
        }
        if (criteria?.minDownlines != null) {
            hql += " AND (leftLegCount + rightLegCount) >= :minDownlines"
            params.minDownlines = criteria.minDownlines
        }
        
        if (criteria?.orderBy) {
            hql += " ORDER BY ${criteria.orderBy} ${criteria.sortOrder ?: 'asc'}"
        }
        
        if (criteria?.max) {
            return Member.executeQuery(hql, params)[0..criteria.max as Integer - 1]
        }
        
        return Member.executeQuery(hql, params)
    }
    
    /**
     * Transfer downlines from one member to another
     */
    Map transferDownlines(String fromUserId, String toUserId) {
        Member fromMember = Member.findByUserId(fromUserId)
        Member toMember = Member.findByUserId(toUserId)
        
        if (!fromMember || !toMember) {
            return [success: false, message: "Member not found"]
        }
        
        def downlines = Member.findAllByParentId(fromMember.id)
        int transferred = 0
        int failed = 0
        
        for (downline in downlines) {
            try {
                downline.sponsorId = toUserId
                downline.parentId = toMember.id
                downline.save(flush: false)
                transferred++
            } catch (Exception e) {
                failed++
            }
        }
        
        return [
            success: true,
            transferred: transferred,
            failed: failed,
            message: "Transferred ${transferred} downlines from ${fromUserId} to ${toUserId}"
        ]
    }
}