package mlm

class UrlMappings {

    static mappings = {
        // Default root - redirect to matrix dashboard
        "/"(view: "/index")
        
        // Matrix controller routes
        "/matrix/dashboard"(controller: "matrix", action: "dashboard")
        "/matrix/visualization/${userId}"(controller: "matrix", action: "visualization")
        "/matrix/genealogy/${userId}"(controller: "matrix", action: "genealogy")
        "/matrix/placement-info/${userId}"(controller: "matrix", action: "placementInfo")
        "/matrix/config-dashboard"(controller: "matrix", action: "configDashboard")
        "/matrix/create-config"(controller: "matrix", action: "createConfigForm")
        "/matrix/save-config"(controller: "matrix", action: "saveConfig")
        "/matrix/edit-config/${id}"(controller: "matrix", action: "editConfig")
        "/matrix/update-config/${id}"(controller: "matrix", action: "updateConfig")
        "/matrix/delete-config/${id}"(controller: "matrix", action: "deleteConfig")
        "/matrix/set-default/${id}"(controller: "matrix", action: "setDefaultConfig")
        "/matrix/quick-placement"(controller: "matrix", action: "quickPlacement")
        "/matrix/perform-placement"(controller: "matrix", action: "performQuickPlacement")
        "/matrix/api/stats"(controller: "matrix", action: "apiStats")
        "/matrix/api/member/${userId}"(controller: "matrix", action: "apiMember")
        
        // Member controller routes (RESTful)
        "/member"(controller: "member", action: "index")
        "/member/create"(controller: "member", action: "create")
        "/member/show/${id}"(controller: "member", action: "show")
        "/member/save"(controller: "member", action: "save")
        "/member/edit/${id}"(controller: "member", action: "edit")
        "/member/update/${id}"(controller: "member", action: "update")
        "/member/delete/${id}"(controller: "member", action: "delete")
        "/member/search"(controller: "member", action: "search")
        "/member/activate/${userId}"(controller: "member", action: "activate")
        "/member/deactivate/${userId}"(controller: "member", action: "deactivate")
        
        // API routes
        "/api/v1/members"(controller: "member", action: "index")
        "/api/v1/members/${id}"(controller: "member", action: "show")
        "/api/v1/members/search"(controller: "member", action: "search")
        "/api/v1/matrix/stats"(controller: "matrix", action: "apiStats")
        "/api/v1/matrix/member/${userId}"(controller: "matrix", action: "apiMember")
        
        // Catch all
        "500"(view: '/error')
        "404"(view: '/notFound')
    }
}