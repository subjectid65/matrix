package mlm

class MatrixConfigService {

    /**
     * Get active matrix configuration
     */
    MatrixConfig getActiveConfig() {
        def config = MatrixConfig.findWhere(status: 'ACTIVE')
        if (!config) {
            return MatrixConfig.getDefaultConfig()
        }
        return config
    }
    
    /**
     * Get config by name
     */
    MatrixConfig getConfigByName(String name) {
        return MatrixConfig.findByConfigName(name)
    }
    
    /**
     * Create or update default configuration
     */
    MatrixConfig updateDefaultConfig(Map configParams) {
        def config = MatrixConfig.findWhere(configName: 'DEFAULT')
        
        if (!config) {
            config = new MatrixConfig(configName: 'DEFAULT')
        }
        
        config.properties = [
            matrixWidth: configParams.matrixWidth ?: 3,
            matrixHeight: configParams.matrixHeight ?: 3,
            maxLevels: configParams.maxLevels ?: 50,
            commissionStructure: configParams.commissionStructure ?: 'MATRIX',
            leftCommissionRate: configParams.leftCommissionRate ?: 50.0,
            rightCommissionRate: configParams.rightCommissionRate ?: 50.0,
            matchingBonusRate: configParams.matchingBonusRate ?: 0.0,
            poolBonusRate: configParams.poolBonusRate ?: 0.0,
            description: configParams.description ?: 'Default Matrix Configuration'
        ]
        
        config.save(flush: true)
        return config
    }
    
    /**
     * Calculate matrix capacity
     */
    Map calculateCapacity(Integer width, Integer height) {
        Integer totalSlots = (width - 1) * height
        Integer leftCapacity = totalSlots / 2
        Integer rightCapacity = totalSlots - leftCapacity
        
        return [
            width: width,
            height: height,
            totalSlots: totalSlots,
            leftCapacity: leftCapacity,
            rightCapacity: rightCapacity,
            maxDepth: height
        ]
    }
    
    /**
     * Validate matrix dimensions
     */
    Map validateDimensions(Integer width, Integer height) {
        def errors = []
        
        if (!width || width < 2) {
            errors.add("Matrix width must be at least 2")
        }
        if (!width || width > 10) {
            errors.add("Matrix width cannot exceed 10")
        }
        if (!height || height < 2) {
            errors.add("Matrix height must be at least 2")
        }
        if (!height || height > 50) {
            errors.add("Matrix height cannot exceed 50")
        }
        
        return [
            valid: errors.isEmpty(),
            errors: errors,
            width: width,
            height: height
        ]
    }
    
    /**
     * Get all configurations
     */
    List<MatrixConfig> getAllConfigs() {
        return MatrixConfig.list([orderBy: 'configName', sortOrder: 'asc'])
    }
    
    /**
     * Activate a configuration
     */
    MatrixConfig activateConfig(Long id) {
        def config = MatrixConfig.get(id)
        if (config) {
            // Deactivate all others
            MatrixConfig.executeUpdate(
                "UPDATE MatrixConfig SET status = 'INACTIVE' WHERE id <> :id",
                [id: id]
            )
            config.status = 'ACTIVE'
            config.save(flush: true)
        }
        return config
    }
    
    /**
     * Clone a configuration
     */
    MatrixConfig cloneConfig(Long sourceId, String newName) {
        def source = MatrixConfig.get(sourceId)
        if (!source) {
            return null
        }
        
        def cloned = new MatrixConfig([
            configName: newName,
            matrixWidth: source.matrixWidth,
            matrixHeight: source.matrixHeight,
            maxLevels: source.maxLevels,
            commissionStructure: source.commissionStructure,
            leftCommissionRate: source.leftCommissionRate,
            rightCommissionRate: source.rightCommissionRate,
            matchingBonusRate: source.matchingBonusRate,
            poolBonusRate: source.poolBonusRate,
            description: "Cloned from ${source.configName}",
            status: 'INACTIVE'
        ])
        
        cloned.save(flush: true)
        return cloned
    }
    
    /**
     * Delete a configuration
     */
    boolean deleteConfig(Long id) {
        def config = MatrixConfig.get(id)
        if (config) {
            // Prevent deletion of active configs with members
            if (config.status == 'ACTIVE') {
                return false
            }
            config.delete(flush: true)
            return true
        }
        return false
    }
    
    /**
     * Predefined matrix templates
     */
    static Map<String, Map> getTemplates() {
        return [
            'small': [
                name: 'Small Matrix',
                width: 2,
                height: 3,
                leftCommissionRate: 50.0,
                rightCommissionRate: 50.0,
                description: '2x3 matrix - 3 slots per leg'
            ],
            'medium': [
                name: 'Medium Matrix',
                width: 3,
                height: 3,
                leftCommissionRate: 50.0,
                rightCommissionRate: 50.0,
                description: '3x3 matrix - 6 slots per leg'
            ],
            'large': [
                name: 'Large Matrix',
                width: 4,
                height: 3,
                leftCommissionRate: 50.0,
                rightCommissionRate: 50.0,
                description: '4x3 matrix - 9 slots per leg'
            ],
            'wide': [
                name: 'Wide Matrix',
                width: 5,
                height: 4,
                leftCommissionRate: 50.0,
                rightCommissionRate: 50.0,
                description: '5x4 matrix - 18 slots per leg'
            ]
        ]
    }
    
    /**
     * Create config from template
     */
    MatrixConfig createFromTemplate(String templateName) {
        def templates = getTemplates()
        def template = templates[templateName]
        
        if (!template) {
            return null
        }
        
        def config = new MatrixConfig(template)
        config.configName = templateName.toUpperCase()
        config.status = 'ACTIVE'
        config.save(flush: true)
        
        return config
    }
}