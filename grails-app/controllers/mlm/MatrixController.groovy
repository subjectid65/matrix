package mlm

import grails.converters.JSON

class MatrixController {

    MatrixService matrixService
    MatrixConfigService matrixConfigService

    static allowedMethods = [createConfig: 'POST', deleteConfig: 'DELETE']

    def dashboard() {
        def stats = matrixService.getOrganizationStatistics()
        def recentMembers = Member.findAllByOrderByJoinDateDesc(max: 5, offset: 0)
        def matrixConfigs = MatrixConfig.findAllActiveConfigs()
        
        [stats: stats, recentMembers: recentMembers, matrixConfigs: matrixConfigs]
    }

    def visualization(String userId) {
        Member member = Member.findByUserId(userId)
        if (!member) {
            flash.message = "Member not found: ${userId}"
            redirect(controller: 'member', action: 'index')
            return
        }
        
        def viz = matrixService.getMatrixVisualization(member)
        def config = matrixService.getMatrixConfig(member)
        def genealogyTree = matrixService.getGenealogyTree(member)
        def legCapacity = ((config?.matrixWidth ?: 3) - 1) * (config?.matrixHeight ?: 3) / 2
        
        [visualization: viz, member: member, config: config, 
         matrixViz: viz, genealogyTree: genealogyTree, legCapacity: legCapacity?.toInteger() ?: 4]
    }

    def genealogy(String userId) {
        Member member = Member.findByUserId(userId)
        if (!member) {
            flash.message = "Member not found: ${userId}"
            redirect(controller: 'member', action: 'index')
            return
        }
        
        def tree = matrixService.getGenealogyTree(member)
        def commissionInfo = matrixService.calculateCommissionEligibility(member)
        
        [tree: tree, member: member, commissionInfo: commissionInfo]
    }

    def placementInfo(String userId) {
        Member member = Member.findByUserId(userId)
        if (!member) {
            render([error: "Member not found: ${userId}"] as grails.converters.JSON)
            return
        }
        
        def config = matrixService.getMatrixConfig(member)
        def placementHistory = matrixService.getPlacementHistory(member)
        
        render (
            [
                member: member,
                config: [
                    width: config.matrixWidth,
                    height: config.matrixHeight,
                    totalSlots: config.totalSlotsPerMember
                ],
                placementHistory: placementHistory.collect { [
                    position: it.placementPosition,
                    direction: it.direction,
                    depth: it.depth,
                    date: it.placementDate
                ]},
                legStatus: [
                    leftCount: member.leftLegCount,
                    rightCount: member.rightLegCount,
                    leftCapacity: ((config.matrixWidth - 1) * config.matrixHeight / 2),
                    rightCapacity: ((config.matrixWidth - 1) * config.matrixHeight / 2)
                ]
            ] as grails.converters.JSON
        )
    }

    def configDashboard() {
        def configs = MatrixConfig.list([orderBy: 'createdAt', sortOrder: 'desc'])
        def stats = matrixService.getOrganizationStatistics()
        
        [configs: configs, stats: stats]
    }

    def createConfigForm() {
        render view: 'createConfig', model: [matrixConfig: new MatrixConfig()]
    }

    def saveConfig() {
        def config = new MatrixConfig(params)
        
        if (!config.hasErrors() && config.save(flush: true)) {
            flash.message = "Matrix configuration '${config.configName}' created successfully"
            redirect(action: 'configDashboard')
        } else {
            render view: 'createConfig', model: [matrixConfig: config]
        }
    }

    def editConfig(Long id) {
        MatrixConfig config = MatrixConfig.get(id)
        if (!config) {
            flash.message = "Configuration not found"
            redirect(action: 'configDashboard')
            return
        }
        
        render view: 'editConfig', model: [matrixConfig: config]
    }

    def updateConfig(Long id) {
        MatrixConfig config = MatrixConfig.get(id)
        if (!config) {
            flash.message = "Configuration not found"
            redirect(action: 'configDashboard')
            return
        }
        
        config.properties = [
            configName: params.configName,
            matrixWidth: params.matrixWidth?.toInteger(),
            matrixHeight: params.matrixHeight?.toInteger(),
            maxLevels: params.maxLevels?.toInteger(),
            commissionStructure: params.commissionStructure,
            leftCommissionRate: params.leftCommissionRate?.toDouble(),
            rightCommissionRate: params.rightCommissionRate?.toDouble(),
            matchingBonusRate: params.matchingBonusRate?.toDouble(),
            poolBonusRate: params.poolBonusRate?.toDouble(),
            description: params.description,
            status: params.status
        ]
        
        if (!config.hasErrors() && config.save(flush: true)) {
            flash.message = "Configuration '${config.configName}' updated successfully"
            redirect(action: 'configDashboard')
        } else {
            render view: 'editConfig', model: [matrixConfig: config]
        }
    }

    def deleteConfig(Long id) {
        MatrixConfig config = MatrixConfig.get(id)
        if (config) {
            def memberCount = Member.count()
            if (memberCount > 0) {
                flash.message = "Cannot delete active configuration with members"
            } else {
                config.delete(flush: true)
                flash.message = "Configuration deleted successfully"
            }
        } else {
            flash.message = "Configuration not found"
        }
        redirect(action: 'configDashboard')
    }

    def setDefaultConfig(Long id) {
        MatrixConfig config = MatrixConfig.get(id)
        if (config) {
            // Deactivate all others
            MatrixConfig.executeUpdate(
                "UPDATE MatrixConfig SET status = 'INACTIVE' WHERE id != :id",
                [id: id]
            )
            config.status = 'ACTIVE'
            config.save(flush: true)
            flash.message = "Configuration '${config.configName}' set as default"
        } else {
            flash.message = "Configuration not found"
        }
        redirect(action: 'configDashboard')
    }

    def quickPlacement() {
        // Quick placement form for testing
        def sponsors = Member.findAllByStatus('ACTIVE').take(20)
        def configs = MatrixConfig.findAllActiveConfigs()
        
        render view: 'quickPlacement', model: [
            sponsors: sponsors,
            matrixConfigs: configs,
            newMember: new Member()
        ]
    }

    def performQuickPlacement() {
        def memberParams = params
        
        def newMember = new Member([
            userId: memberParams.newUserId,
            userName: memberParams.newUserName,
            fullName: memberParams.newFullName,
            email: memberParams.newEmail,
            phoneNumber: memberParams.phoneNumber,
            password: memberParams.password ?: 'password123',
            sponsorId: memberParams.sponsorId,
            matrixWidth: memberParams.matrixWidth?.toInteger() ?: 3,
            matrixHeight: memberParams.matrixHeight?.toInteger() ?: 3
        ])
        
        def result = matrixService.placeMember(newMember, memberParams.sponsorId)
        
        if (result.success) {
            render([
                success: true,
                message: result.message,
                data: [
                    member: result.placedMember,
                    parent: result.parent,
                    position: result.placementPosition,
                    direction: result.direction,
                    depth: result.depth
                ]
            ] as grails.converters.JSON)
        } else {
            render([
                success: false,
                message: result.message
            ] as grails.converters.JSON)
        }
    }

    def apiStats() {
        def stats = matrixService.getOrganizationStatistics()
        render stats as grails.converters.JSON
    }

    def apiMember(String userId) {
        Member member = Member.findByUserId(userId)
        if (!member) {
            respond status: 404, model: [error: "Member not found"]
            return
        }
        
        def viz = matrixService.getMatrixVisualization(member)
        def tree = matrixService.getGenealogyTree(member)
        def commission = matrixService.calculateCommissionEligibility(member)
        
        render (
            [
                member: member,
                matrix: viz,
                genealogy: tree,
                commission: commission
            ] as grails.converters.JSON
        )
    }
}
