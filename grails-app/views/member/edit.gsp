<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Edit Member - ${member?.userId}</title>
</head>
<body>
    <div class="container-fluid">
        <nav aria-label="breadcrumb" class="mb-3">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${createLink(uri: '/')}">Dashboard</a></li>
                <li class="breadcrumb-item"><a href="${createLink(uri: '/member')}">Members</a></li>
                <li class="breadcrumb-item"><a href="${createLink(uri: '/member/show/' + member.id)}">${member?.userId}</a></li>
                <li class="breadcrumb-item active">Edit</li>
            </ol>
        </nav>
        
        <div class="row">
            <div class="col-lg-8 mx-auto">
                <div class="card">
                    <div class="card-header bg-warning text-dark">
                        <h5 class="mb-0"><i class="fas fa-edit"></i> Edit Member: ${member?.userId}</h5>
                    </div>
                    <div class="card-body">
                        <g:if test="${member?.hasErrors() && member?.errors?.allErrors}">
                            <div class="alert alert-danger">
                                <ul class="mb-0">
                                    <g:each var="err" in="${member?.errors?.allErrors}">
                                        <li>${err?.defaultMessage}</li>
                                    </g:each>
                                </ul>
                            </div>
                        </g:if>
                        
                        <form action="${createLink(uri: '/member/update/' + member.id)}" method="POST">
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">User ID</label>
                                    <input type="text" class="form-control" value="${member?.userId}" disabled>
                                </div>
                                
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Username</label>
                                    <input type="text" class="form-control" value="${member?.userName}" disabled>
                                </div>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="fullName" class="form-label">Full Name</label>
                                    <input type="text" class="form-control" id="fullName" name="fullName" value="${member?.fullName ?: ''}">
                                </div>
                                
                                <div class="col-md-6 mb-3">
                                    <label for="email" class="form-label">Email</label>
                                    <input type="email" class="form-control" id="email" name="email" value="${member?.email ?: ''}">
                                </div>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="phoneNumber" class="form-label">Phone Number</label>
                                    <input type="text" class="form-control" id="phoneNumber" name="phoneNumber" value="${member?.phoneNumber ?: ''}">
                                </div>
                                
                                <div class="col-md-6 mb-3">
                                    <label for="status" class="form-label">Status</label>
                                    <select class="form-select" id="status" name="status">
                                        <option value="PENDING" ${member?.status == 'PENDING' ? 'selected' : ''}>Pending</option>
                                        <option value="ACTIVE" ${member?.status == 'ACTIVE' ? 'selected' : ''}>Active</option>
                                        <option value="INACTIVE" ${member?.status == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
                                        <option value="BANNED" ${member?.status == 'BANNED' ? 'selected' : ''}>Banned</option>
                                    </select>
                                </div>
                            </div>
                            
                            <hr class="my-4">
                            <h6><i class="fas fa-info-circle"></i> Read-Only Information</h6>
                            
                            <div class="row">
                                <div class="col-md-4 mb-3">
                                    <label class="form-label">Sponsor</label>
                                    <input type="text" class="form-control" value="${member?.sponsorId ?: 'Root'}" disabled>
                                </div>
                                <div class="col-md-4 mb-3">
                                    <label class="form-label">Position</label>
                                    <input type="text" class="form-control" value="${member?.placementPosition ?: 'ROOT'}" disabled>
                                </div>
                                <div class="col-md-4 mb-3">
                                    <label class="form-label">Level</label>
                                    <input type="text" class="form-control" value="${member?.level ?: 0}" disabled>
                                </div>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-4 mb-3">
                                    <label class="form-label">Left Leg</label>
                                    <input type="text" class="form-control" value="${member?.leftLegCount ?: 0}" disabled>
                                </div>
                                <div class="col-md-4 mb-3">
                                    <label class="form-label">Right Leg</label>
                                    <input type="text" class="form-control" value="${member?.rightLegCount ?: 0}" disabled>
                                </div>
                                <div class="col-md-4 mb-3">
                                    <label class="form-label">Join Date</label>
                                    <input type="text" class="form-control" value="${member?.joinDate ?: ''}" disabled>
                                </div>
                            </div>
                            
                            <hr class="my-4">
                            
                            <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                <a href="${createLink(uri: '/member/show/' + member.id)}" class="btn btn-secondary">
                                    <i class="fas fa-times"></i> Cancel
                                </a>
                                <button type="submit" class="btn btn-warning">
                                    <i class="fas fa-save"></i> Update Member
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>