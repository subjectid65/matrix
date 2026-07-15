package mlm

import java.sql.Timestamp
import groovy.transform.ToString

@ToString(includes = 'id,userId,userName,sponsorId,leftLegCount,rightLegCount,position,status')
class Member {

    String userId
    String userName
    String fullName
    String email
    String phoneNumber
    String password
    String sponsorId  // Upline member ID who recruited this member
    Long parentId     // Direct parent in matrix
    
    // Matrix plan fields
    Integer matrixWidth       // Number of columns in matrix (default 3)
    Integer matrixHeight      // Number of rows in matrix (default 3)
    Integer position          // Position in matrix (0 = root, 1+ = placed position)
    Integer leftLegCount      // Count of members in left leg
    Integer rightLegCount     // Count of members in right leg
    String placementPosition  // e.g., "L1" (left row 1), "R2" (right row 2), "ROOT"
    String direction          // LEFT, RIGHT, or CENTER
    
    // Status and dates
    String status             // PENDING, ACTIVE, INACTIVE, BANNED
    Date joinDate
    Timestamp createdAt
    Timestamp updatedAt
    
    // Level in the organization (0 = root/unranked)
    Integer level
    
    static transients = [
        'leftChildren', 'rightChildren', 'downlineCount', 'matrixGrid'
    ]
    
    static mapping = {
        table 'mlm_member'
        id generator: 'increment'
        userId type: 'text'
        userName type: 'text'
        fullName type: 'text'
        email type: 'text'
        password type: 'text'
        sponsorId type: 'text'
        placementPosition type: 'text'
        direction type: 'text'
        joinDate sqlType: 'timestamp'
        createdAt sqlType: 'timestamp'
        updatedAt sqlType: 'timestamp'
    }
    
    static constraints = {
        userId nullable: false, unique: true, blank: false, size: 1..50
        userName nullable: false, blank: false, size: 1..50
        fullName nullable: true, blank: false, size: 1..100
        email nullable: true, email: true, blank: false, validator: { val, obj ->
            if (val != null && !val.isEmpty()) {
                return Member.countByEmail(val) == 0
            }
            return true
        }
        phoneNumber nullable: true, blank: true, matches: /^[0-9+\-\s()]*$/
        password nullable: false, blank: false, size: 6..100
        sponsorId nullable: true, blank: true, size: 1..50
        matrixWidth nullable: true, inList: 2..5, defaultValue: 3
        matrixHeight nullable: true, inList: 2..5, defaultValue: 3
        position nullable: true, inList: 0..1000
        leftLegCount nullable: true, defaultValue: 0
        rightLegCount nullable: true, defaultValue: 0
        placementPosition nullable: true, blank: true
        direction nullable: true, inList: ['LEFT', 'RIGHT', 'CENTER']
        status nullable: false, inList: ['PENDING', 'ACTIVE', 'INACTIVE', 'BANNED'], defaultValue: 'PENDING'
        joinDate nullable: true
        level nullable: true, defaultValue: 0
    }
    
    def beforeInsert() {
        createdAt = new Timestamp(System.currentTimeMillis())
        updatedAt = createdAt
        if (!joinDate) {
            joinDate = new Date()
        }
    }
    
    def beforeUpdate() {
        updatedAt = new Timestamp(System.currentTimeMillis())
    }
    
    // Computed property: get total downline count
    Integer getDownlineCount() {
        return Member.countByParentId(id)
    }
    
    // Get left children members
    List<Member> getLeftChildren() {
        return Member.findAllByParentIdAndPlacementPositionLike(id, 'L%')
    }
    
    // Get right children members
    List<Member> getRightChildren() {
        return Member.findAllByParentIdAndPlacementPositionLike(id, 'R%')
    }
    
    // Get matrix grid representation
    String[][] getMatrixGrid() {
        int width = matrixWidth ?: 3
        int height = matrixHeight ?: 3
        String[][] grid = new String[height][width]
        
        // Initialize grid with empty
        for (int i = 0; i < height; i++) {
            for (int j = 0; j < width; j++) {
                grid[i][j] = ''
            }
        }
        
        // Place self at root
        grid[0][0] = userId
        
        // Get children and place them
        def children = Member.findAllByParentId(id)
        children.eachWithIndex { child, idx ->
            int row = (idx / (width - 1)) as int + 1
            int col = idx % (width - 1) + 1
            if (row < height && col < width) {
                grid[row][col] = child.userId
            }
        }
        
        return grid
    }
    
    // Check if member has a sponsor
    boolean isRoot() {
        return parentId == null || parentId == 0
    }
    
    // Get sponsor/upline member
    Member getSponsor() {
        if (sponsorId) {
            return Member.findByUserId(sponsorId)
        }
        return null
    }
    
    // Calculate total downlines recursively
    int getTotalDownlines() {
        def directDownlines = Member.findAllByParentId(id)
        int total = directDownlines.size()
        for (Member downline : directDownlines) {
            total += downline.getTotalDownlines()
        }
        return total
    }
    
    // Check if a leg is full (all positions filled)
    boolean isLeftLegFull() {
        return leftLegCount >= ((matrixWidth ?: 3) - 1) * (matrixHeight ?: 3)
    }
    
    boolean isRightLegFull() {
        return rightLegCount >= ((matrixWidth ?: 3) - 1) * (matrixHeight ?: 3)
    }
    
    boolean isLegFull(String leg) {
        if ('LEFT'.equalsIgnoreCase(leg)) {
            return isLeftLegFull()
        }
        return isRightLegFull()
    }
}