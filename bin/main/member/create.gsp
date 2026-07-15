<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Create Member - MLM Matrix Plan</title>
</head>
<body>
    <div class="container-fluid">
        <nav aria-label="breadcrumb" class="mb-3">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${createLink(uri: '/')}">Dashboard</a></li>
                <li class="breadcrumb-item"><a href="${createLink(uri: '/member')}">Members</a></li>
                <li class="breadcrumb-item active">Create Member</li>
            </ol>
        </nav>
        
        <div class="row">
            <div class="col-lg-8 mx-auto">
                <div class="card">
                    <div class="card-header bg-primary text-white">
                        <h5 class="mb-0"><i class="fas fa-user-plus"></i> Register New Member</h5>
                    </div>
                    <div class="card-body">
                        <g:if test="${member?.hasErrors() && member?.errors?.allErrors}">
                            <div class="alert alert-danger">
                                <h6>Please fix the following errors:</h6>
                                <ul class="mb-0">
                                    <g:each var="err" in="${member?.errors?.allErrors}">
                                        <li>${err?.defaultMessage}</li>
                                    </g:each>
                                </ul>
                            </div>
                        </g:if>
                        
                        <form action="${createLink(uri: '/member/save')}" method="POST">
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="userId" class="form-label">User ID <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control ${member?.errors?.getFieldError('userId') ? 'is-invalid' : ''}" 
                                           id="userId" name="userId" value="${member?.userId ?: ''}" required>
                                    <div class="form-text">Unique identifier for the member</div>
                                    <g:if test="${member?.errors?.getFieldError('userId')}">
                                        <div class="invalid-feedback">${member?.errors?.getFieldError('userId')?.defaultMessage}</div>
                                    </g:if>
                                </div>
                                
                                <div class="col-md-6 mb-3">
                                    <label for="userName" class="form-label">Username <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control ${member?.errors?.getFieldError('userName') ? 'is-invalid' : ''}" 
                                           id="userName" name="userName" value="${member?.userName ?: ''}" required>
                                    <g:if test="${member?.errors?.getFieldError('userName')}">
                                        <div class="invalid-feedback">${member?.errors?.getFieldError('userName')?.defaultMessage}</div>
                                    </g:if>
                                </div>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="fullName" class="form-label">Full Name</label>
                                    <input type="text" class="form-control" id="fullName" name="fullName" 
                                           value="${member?.fullName ?: ''}">
                                </div>
                                
                                <div class="col-md-6 mb-3">
                                    <label for="email" class="form-label">Email</label>
                                    <input type="email" class="form-control ${member?.errors?.getFieldError('email') ? 'is-invalid' : ''}" 
                                           id="email" name="email" value="${member?.email ?: ''}">
                                    <g:if test="${member?.errors?.getFieldError('email')}">
                                        <div class="invalid-feedback">${member?.errors?.getFieldError('email')?.defaultMessage}</div>
                                    </g:if>
                                </div>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="phoneNumber" class="form-label">Phone Number</label>
                                    <input type="text" class="form-control" id="phoneNumber" name="phoneNumber" 
                                           value="${member?.phoneNumber ?: ''}">
                                </div>
                                
                                <div class="col-md-6 mb-3">
                                    <label for="password" class="form-label">Password <span class="text-danger">*</span></label>
                                    <input type="password" class="form-control ${member?.errors?.getFieldError('password') ? 'is-invalid' : ''}" 
                                           id="password" name="password" required minlength="6">
                                    <div class="form-text">Minimum 6 characters</div>
                                    <g:if test="${member?.errors?.getFieldError('password')}">
                                        <div class="invalid-feedback">${member?.errors?.getFieldError('password')?.defaultMessage}</div>
                                    </g:if>
                                </div>
                            </div>
                            
                            <hr class="my-4">
                            <h6><i class="fas fa-sitemap"></i> Matrix Placement</h6>
                            
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="sponsorId" class="form-label">Sponsor/User ID</label>
                                    <select class="form-select ${member?.errors?.getFieldError('sponsorId') ? 'is-invalid' : ''}" 
                                            id="sponsorId" name="sponsorId">
                                        <option value="">-- Root Member (No Sponsor) --</option>
                                        <g:each in="${sponsors}" var="s">
                                            <option value="${s.userId}" ${member?.sponsorId == s.userId ? 'selected' : ''}>
                                                ${s.displayName}
                                            </option>
                                        </g:each>
                                    </select>
                                    <div class="form-text">Select the sponsor who recruited this member</div>
                                </div>
                                
                                <div class="col-md-3 mb-3">
                                    <label for="matrixWidth" class="form-label">Matrix Width</label>
                                    <select class="form-select" id="matrixWidth" name="matrixWidth">
                                        <g:each var="w" in="[2, 3, 4, 5]">
                                            <option value="${w}" ${(!member?.matrixWidth || member?.matrixWidth == w) ? 'selected' : ''}>${w}</option>
                                        </g:each>
                                    </select>
                                </div>
                                
                                <div class="col-md-3 mb-3">
                                    <label for="matrixHeight" class="form-label">Matrix Height</label>
                                    <select class="form-select" id="matrixHeight" name="matrixHeight">
                                        <g:each var="hh" in="[2, 3, 4, 5]">
                                            <option value="${hh}" ${(!member?.matrixHeight || member?.matrixHeight == hh) ? 'selected' : ''}>${hh}</option>
                                        </g:each>
                                    </select>
                                </div>
                            </div>
                            
                            <!-- Matrix Preview -->
                            <div class="alert alert-info mb-3">
                                <h6><i class="fas fa-info-circle"></i> Matrix Capacity Preview</h6>
                                <div class="row text-center">
                                    <div class="col-4">
                                        <strong>Width:</strong> <span id="previewWidth">3</span>
                                    </div>
                                    <div class="col-4">
                                        <strong>Height:</strong> <span id="previewHeight">3</span>
                                    </div>
                                    <div class="col-4">
                                        <strong>Slots/Leg:</strong> <span id="previewSlots">4</span>
                                    </div>
                                </div>
                            </div>
                            
                            <hr class="my-4">
                            
                            <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                <a href="${createLink(uri: '/member')}" class="btn btn-secondary">
                                    <i class="fas fa-times"></i> Cancel
                                </a>
                                <button type="submit" class="btn btn-primary">
                                    <i class="fas fa-save"></i> Create & Place Member
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const widthSelect = document.getElementById('matrixWidth');
            const heightSelect = document.getElementById('matrixHeight');
            
            function updatePreview() {
                const w = parseInt(widthSelect.value) || 3;
                const h = parseInt(heightSelect.value) || 3;
                const slots = (w - 1) * h / 2;
                
                document.getElementById('previewWidth').textContent = w;
                document.getElementById('previewHeight').textContent = h;
                document.getElementById('previewSlots').textContent = Math.floor(slots);
            }
            
            widthSelect.addEventListener('change', updatePreview);
            heightSelect.addEventListener('change', updatePreview);
            updatePreview();
        });
    </script>
</body>
</html>