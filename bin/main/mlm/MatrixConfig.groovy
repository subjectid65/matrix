package mlm

import java.sql.Timestamp

/**
 * Configuration for Matrix Plan settings
 */
class MatrixConfig {

    String configName
    Integer matrixWidth        // Number of columns (slots per level)
    Integer matrixHeight       // Maximum depth/rows
    Integer maxLevels          // Maximum levels deep
    String commissionStructure // COMPREV, Binary, Unilevel, etc.
    
    // Commission rates (percentage)
    Double leftCommissionRate
    Double rightCommissionRate
    Double matchingBonusRate
    Double poolBonusRate
    
    String status              // ACTIVE, INACTIVE
    String description
    Timestamp createdAt
    Timestamp updatedAt
    
    static transients = ['totalSlotsPerMember', 'isLegFullThreshold']
    
    static mapping = {
        table 'mlm_matrix_config'
        id generator: 'increment'
        configName column: 'config_name'
        description column: 'description', type: 'text'
        commissionStructure column: 'commission_structure', type: 'text'
        createdAt sqlType: 'timestamp'
        updatedAt sqlType: 'timestamp'
    }
    
    static constraints = {
        configName nullable: false, unique: true, blank: false, size: 1..50
        matrixWidth nullable: false, inList: 2..5, defaultValue: 3
        matrixHeight nullable: false, inList: 2..10, defaultValue: 3
        maxLevels nullable: true, inList: 1..50, defaultValue: 50
        commissionStructure nullable: true, blank: false, size: 1..50
        leftCommissionRate nullable: true, min: 0.0d, max: 100.0d
        rightCommissionRate nullable: true, min: 0.0d, max: 100.0d
        matchingBonusRate nullable: true, min: 0.0d, max: 100.0d
        poolBonusRate nullable: true, min: 0.0d, max: 100.0d
        status nullable: false, inList: ['ACTIVE', 'INACTIVE'], defaultValue: 'ACTIVE'
        description nullable: true
    }
    
    def beforeInsert() {
        createdAt = new Timestamp(System.currentTimeMillis())
        updatedAt = createdAt
        if (!commissionStructure) {
            commissionStructure = 'MATRIX'
        }
        if (!leftCommissionRate) leftCommissionRate = 50.0
        if (!rightCommissionRate) rightCommissionRate = 50.0
    }
    
    def beforeUpdate() {
        updatedAt = new Timestamp(System.currentTimeMillis())
    }
    
    // Get total slots per member (excluding root)
    Integer getTotalSlotsPerMember() {
        return (matrixWidth - 1) * matrixHeight
    }
    
    // Get the threshold for considering a leg "full"
    Integer getLegFullThreshold() {
        return (matrixWidth - 1) * matrixHeight / 2
    }
    
    // Get all active matrix configs
    static List<MatrixConfig> findActiveConfigs() {
        return MatrixConfig.findAllByStatus('ACTIVE')
    }
    
    // Get default config
    static MatrixConfig getDefaultConfig() {
        def config = MatrixConfig.findWhere(configName: 'DEFAULT')
        if (!config) {
            config = new MatrixConfig(
                configName: 'DEFAULT',
                matrixWidth: 3,
                matrixHeight: 3,
                leftCommissionRate: 50.0,
                rightCommissionRate: 50.0,
                status: 'ACTIVE'
            )
            config.save(flush: true)
        }
        return config
    }
}