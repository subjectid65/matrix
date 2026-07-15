package mlm

import org.springframework.http.HttpStatus

class MemberController {

    MatrixService matrixService
    MemberService memberService

    static allowedMethods = [save: 'POST', update: 'PUT', delete: 'DELETE']

    def index() {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        params.offset = params.offset ? params.int('offset') : 0
        
        def members = memberService.listMembers(params)
        def total = Member.count()
        
        [members: members.members, total: total, totalPages: members.totalPages, 
         currentPage: members.currentPage, memberStats: memberService.getMemberStats()]
    }

    def show(Long id) {
        Member member = Member.get(id)
        if (!member) {
            flash.message = "Member not found with id: ${id}"
            redirect(action: 'index')
            return
        }
        
        def genealogyTree = matrixService.getGenealogyTree(member)
        def matrixViz = matrixService.getMatrixVisualization(member)
        def commissionInfo = matrixService.calculateCommissionEligibility(member)
        def placementHistory = matrixService.getPlacementHistory(member)
        def sponsor = member.sponsor
        def config = matrixService.getMatrixConfig(member)
        def legCapacity = ((config?.matrixWidth ?: 3) - 1) * (config?.matrixHeight ?: 3) / 2
        
        [member: member, genealogyTree: genealogyTree, matrixViz: matrixViz,
         commissionInfo: commissionInfo, placementHistory: placementHistory, sponsor: sponsor,
         legCapacity: legCapacity?.toInteger() ?: 4]
    }

    def create() {
        def member = new Member()
        def sponsors = Member.findAllByStatus('ACTIVE').collect { [userId: it.userId, displayName: "${it.userId} (${it.fullName})"] }
        
        [member: member, sponsors: sponsors, matrixConfigs: MatrixConfig.findAllActiveConfigs()]
    }

    def save() {
        def memberParams = params.allParams
        
        // Extract only member fields
        def memberData = [
            userId: memberParams.userId,
            userName: memberParams.userName,
            fullName: memberParams.fullName,
            email: memberParams.email,
            phoneNumber: memberParams.phoneNumber,
            password: memberParams.password,
            sponsorId: memberParams.sponsorId,
            matrixWidth: memberParams.matrixWidth?.toInteger() ?: 3,
            matrixHeight: memberParams.matrixHeight?.toInteger() ?: 3,
            level: memberParams.level?.toInteger() ?: 0
        ]
        
        def member = new Member(memberData)
        
        try {
            def result = matrixService.placeMember(member, memberData.sponsorId)
            
            if (result.success) {
                flash.message = "Member ${result.placedMember?.userId} placed successfully at position ${result.placementPosition}"
                flash.type = "success"
                redirect(action: 'show', id: result.placedMember?.id)
            } else {
                member.errors.rejectValue('userId', '', result.message)
                render(view: 'create', model: [
                    member: member,
                    sponsors: Member.findAllByStatus('ACTIVE').collect { [userId: it.userId, displayName: "${it.userId} (${it.fullName})"] },
                    matrixConfigs: MatrixConfig.findAllActiveConfigs()
                ])
            }
        } catch (Exception e) {
            member.errors.rejectValue('userId', '', "Error creating member: ${e.message}")
            render(view: 'create', model: [
                member: member,
                sponsors: Member.findAllByStatus('ACTIVE').collect { [userId: it.userId, displayName: "${it.userId} (${it.fullName})"] },
                matrixConfigs: MatrixConfig.findAllActiveConfigs()
            ])
        }
    }

    def edit(Long id) {
        Member member = Member.get(id)
        if (!member) {
            flash.message = "Member not found with id: ${id}"
            redirect(action: 'index')
            return
        }
        
        def sponsors = Member.findAllByStatus('ACTIVE').collect { [userId: it.userId, displayName: "${it.userId} (${it.fullName})"] }
        
        [member: member, sponsors: sponsors]
    }

    def update(Long id) {
        Member member = Member.get(id)
        if (!member) {
            flash.message = "Member not found with id: ${id}"
            redirect(action: 'index')
            return
        }
        
        def memberParams = params.allParams
        member.properties = [
            fullName: memberParams.fullName,
            email: memberParams.email,
            phoneNumber: memberParams.phoneNumber,
            status: memberParams.status
        ]
        
        if (member.hasErrors() || !member.save(flush: true)) {
            flash.message = "Failed to update member: ${member.errors.allErrors*.defaultMessage.join(', ')}"
            redirect(action: 'edit', id: member.id)
            return
        }
        
        flash.message = "Member ${member.userId} updated successfully"
        redirect(action: 'show', id: member.id)
    }

    def delete(Long id) {
        Member member = Member.get(id)
        if (!member) {
            flash.message = "Member not found with id: ${id}"
            redirect(action: 'index')
            return
        }
        
        // Check if member has downlines
        def downlineCount = member.totalDownlines
        if (downlineCount > 0) {
            flash.message = "Cannot delete member with ${downlineCount} downline(s). Please reassign or remove downlines first."
            redirect(action: 'show', id: member.id)
            return
        }
        
        member.delete(flush: true)
        flash.message = "Member ${member.userId} deleted successfully"
        redirect(action: 'index')
    }

    def search() {
        def criteria = [
            userId: params.q,
            userName: params.q,
            fullName: params.q,
            status: params.status,
            sponsorId: params.sponsorId,
            minLevel: params.minLevel?.toInteger(),
            maxLevel: params.maxLevel?.toInteger()
        ]
        
        def members = matrixService.searchMembers(criteria)
        def total = members.size()
        
        // Pagination
        params.max = Math.min(params.max ? params.int('max') : 20, 100)
        params.offset = params.offset ? params.int('offset') : 0
        def paginatedMembers = members ? members.subList(
            Math.min(params.offset, members.size()),
            Math.min(params.offset + params.max, members.size())
        ) : []
        
        render (
            [
                members: paginatedMembers,
                total: total,
                currentPage: params.offset ? (params.int('offset') / params.max) + 1 : 1,
                totalPages: (int) Math.ceil((double) total / params.max)
            ] as grails.converters.JSON
        )
    }

    def activate(String userId) {
        def result = matrixService.activateMember(userId)
        if (result.success) {
            flash.message = "Member ${userId} activated successfully"
        } else {
            flash.message = result.message
        }
        redirect(action: 'show', id: Member.findByUserId(userId)?.id)
    }

    def deactivate(String userId) {
        def result = matrixService.deactivateMember(userId)
        if (result.success) {
            flash.message = "Member ${userId} deactivated successfully"
        } else {
            flash.message = result.message
        }
        redirect(action: 'show', id: Member.findByUserId(userId)?.id)
    }

    def downlineTree(Long id) {
        Member member = Member.get(id)
        if (!member) {
            respond status: HttpStatus.NOT_FOUND
            return
        }
        
        def tree = matrixService.getGenealogyTree(member)
        render view: 'downlineTree', model: [member: member, tree: tree], contentType: 'text/html'
    }
}