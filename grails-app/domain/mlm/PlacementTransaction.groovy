package mlm

import java.sql.Timestamp

class PlacementTransaction {

    Member member           // The newly placed member
    Member sponsor          // The sponsor/upline
    Member parent           // The direct parent in matrix
    String placementPosition // Position string (e.g., "L1", "R2", "ROOT")
    String direction         // LEFT or RIGHT
    
    // Leg counts at time of placement
    Integer parentLeftCountBefore
    Integer parentRightCountBefore
    Integer parentLeftCountAfter
    Integer parentRightCountAfter
    
    String matrixWidth
    String matrixHeight
    String resultMessage
    Integer depth            // Depth in the matrix
    
    Date placementDate
    Timestamp createdAt
    
    static mapping = {
        table 'mlm_placement_transaction'
        id generator: 'increment'
        member column: 'member_id'
        sponsor column: 'sponsor_id'
        parent column: 'parent_id'
        placementPosition column: 'placement_position'
        resultMessage column: 'result_message', type: 'text'
        placementDate sqlType: 'timestamp'
        createdAt sqlType: 'timestamp'
    }
    
    static constraints = {
        member nullable: false
        sponsor nullable: true
        parent nullable: true
        placementPosition nullable: true
        direction nullable: true, inList: ['LEFT', 'RIGHT', 'CENTER']
        matrixWidth nullable: true
        matrixHeight nullable: true
        resultMessage nullable: true
        depth nullable: true, defaultValue: 0
        placementDate nullable: false
    }
    
    def beforeInsert() {
        createdAt = new Timestamp(System.currentTimeMillis())
        placementDate = createdAt
    }
    
    def beforeUpdate() {
        // No automatic updates needed
    }
}