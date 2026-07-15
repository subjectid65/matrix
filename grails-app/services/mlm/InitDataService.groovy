package mlm

import org.springframework.boot.CommandLineRunner
import org.springframework.stereotype.Component

/**
 * Service to initialize default data for the MLM system
 */
@Component
class InitDataService implements CommandLineRunner {

    void run(String... args) throws Exception {
        initializeDefaultData()
    }
    
    private void initializeDefaultData() {
        // Create default matrix configuration if not exists
        if (!MatrixConfig.findWhere(configName: 'DEFAULT')) {
            def defaultConfig = new MatrixConfig(
                configName: 'DEFAULT',
                matrixWidth: 3,
                matrixHeight: 3,
                maxLevels: 50,
                commissionStructure: 'MATRIX',
                leftCommissionRate: 50.0,
                rightCommissionRate: 50.0,
                matchingBonusRate: 5.0,
                poolBonusRate: 2.0,
                status: 'ACTIVE',
                description: 'Default matrix configuration for MLM system'
            )
            defaultConfig.save(flush: true)
            println "Created default matrix configuration"
        }
        
        // Create sample root members if no members exist
        if (Member.count() == 0) {
            createSampleMembers()
        }
    }
    
    private void createSampleMembers() {
        // Create root member
        def root1 = new Member(
            userId: 'ROOT001',
            userName: 'root001',
            fullName: 'John Smith',
            email: 'root001@example.com',
            phoneNumber: '+1-555-0101',
            password: 'password123',
            sponsorId: null,
            matrixWidth: 3,
            matrixHeight: 3,
            status: 'ACTIVE',
            level: 0
        )
        root1.save(flush: true)
        println "Created root member: ROOT001"
        
        // Create second root member
        def root2 = new Member(
            userId: 'ROOT002',
            userName: 'root002',
            fullName: 'Jane Doe',
            email: 'root002@example.com',
            phoneNumber: '+1-555-0102',
            password: 'password123',
            sponsorId: null,
            matrixWidth: 3,
            matrixHeight: 3,
            status: 'ACTIVE',
            level: 0
        )
        root2.save(flush: true)
        println "Created root member: ROOT002"
        
        // Inject MatrixService
        MatrixService matrixService
        
        def sampleMembers = [
            [userId: 'MEM001', userName: 'alice_w', fullName: 'Alice Walker', email: 'alice@example.com', sponsorId: 'ROOT001'],
            [userId: 'MEM002', userName: 'bob_j', fullName: 'Bob Johnson', email: 'bob@example.com', sponsorId: 'ROOT001'],
            [userId: 'MEM003', userName: 'carol_s', fullName: 'Carol Smith', email: 'carol@example.com', sponsorId: 'MEM001'],
            [userId: 'MEM004', userName: 'dave_b', fullName: 'Dave Brown', email: 'dave@example.com', sponsorId: 'MEM001'],
            [userId: 'MEM005', userName: 'eve_m', fullName: 'Eve Miller', email: 'eve@example.com', sponsorId: 'MEM002'],
            [userId: 'MEM006', userName: 'frank_w', fullName: 'Frank Wilson', email: 'frank@example.com', sponsorId: 'MEM002'],
            [userId: 'MEM007', userName: 'grace_l', fullName: 'Grace Lee', email: 'grace@example.com', sponsorId: 'MEM003'],
            [userId: 'MEM008', userName: 'henry_t', fullName: 'Henry Taylor', email: 'henry@example.com', sponsorId: 'MEM003'],
            [userId: 'MEM009', userName: 'iris_a', fullName: 'Iris Anderson', email: 'iris@example.com', sponsorId: 'MEM004'],
            [userId: 'MEM010', userName: 'jack_p', fullName: 'Jack Thomas', email: 'jack@example.com', sponsorId: 'MEM004'],
        ]
        
        for (int i = 0; i < sampleMembers.size(); i++) {
            def data = sampleMembers[i]
            try {
                def member = new Member([
                    userId: data.userId,
                    userName: data.userName,
                    fullName: data.fullName,
                    email: data.email,
                    password: 'password123',
                    sponsorId: data.sponsorId,
                    matrixWidth: 3,
                    matrixHeight: 3,
                    status: 'ACTIVE'
                ])
                
                def result = matrixService.placeMember(member, data.sponsorId)
                if (result.success) {
                    println "Created member: ${data.userId} placed at ${result.placementPosition}"
                } else {
                    println "Failed to place ${data.userId}: ${result.message}"
                }
            } catch (Exception e) {
                println "Error creating ${data.userId}: ${e.message}"
            }
        }
        
        println "\n=== Sample Data Created ==="
        println "Total members: ${Member.count()}"
        println "Active members: ${Member.countByStatus('ACTIVE')}"
        println "=========================="
    }
}