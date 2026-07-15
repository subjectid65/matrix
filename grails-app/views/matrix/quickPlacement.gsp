<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Quick Placement - MLM Matrix Plan</title>
</head>
<body>
    <div class="container-fluid">
        <nav aria-label="breadcrumb" class="mb-3">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${createLink(uri: '/')}">Dashboard</a></li>
                <li class="breadcrumb-item active">Quick Placement</li>
            </ol>
        </nav>
        
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2><i class="fas fa-bolt"></i> Quick Placement</h2>
            <a href="${createLink(uri: '/member')}" class="btn btn-outline-secondary">
                <i class="fas fa-arrow-left"></i> Back to Members
            </a>
        </div>
        
        <div class="row">
            <div class="col-lg-8">
                <div class="card">
                    <div class="card-header bg-success text-white">
                        <h5 class="mb-0"><i class="fas fa-user-plus"></i> Register & Place New Member</h5>
                    </div>
                    <div class="card-body">
                        <div id="placementResult"></div>
                        
                        <form id="quickPlacementForm">
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="newUserId" class="form-label">User ID <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="newUserId" name="newUserId" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="newUserName" class="form-label">Username <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="newUserName" name="newUserName" required>
                                </div>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="newFullName" class="form-label">Full Name</label>
                                    <input type="text" class="form-control" id="newFullName" name="newFullName">
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="newEmail" class="form-label">Email</label>
                                    <input type="email" class="form-control" id="newEmail" name="newEmail">
                                </div>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="sponsorId" class="form-label">Sponsor/User ID <span class="text-danger">*</span></label>
                                    <select class="form-select" id="sponsorId" name="sponsorId" required>
                                        <option value="">-- Select Sponsor (or leave empty for root) --</option>
                                        <g:each in="${sponsors}" var="s">
                                            <option value="${s.userId}">${s.userId} (${s.fullName})</option>
                                        </g:each>
                                    </select>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="password" class="form-label">Password</label>
                                    <input type="password" class="form-control" id="password" name="password" value="password123">
                                </div>
                            </div>
                            
                            <hr>
                            <h6><i class="fas fa-cog"></i> Matrix Settings</h6>
                            
                            <div class="row">
                                <div class="col-md-4 mb-3">
                                    <label for="matrixWidth" class="form-label">Width</label>
                                    <select class="form-select" id="matrixWidth" name="matrixWidth">
                                        <g:each var="w" in="[2, 3, 4, 5]">
                                            <option value="${w}" ${w == 3 ? 'selected' : ''}>${w}</option>
                                        </g:each>
                                    </select>
                                </div>
                                <div class="col-md-4 mb-3">
                                    <label for="matrixHeight" class="form-label">Height</label>
                                    <select class="form-select" id="matrixHeight" name="matrixHeight">
                                        <g:each var="h1" in="[2, 3, 4, 5]">
                                            <option value="${h1}" ${h1 == 3 ? 'selected' : ''}>${h1}</option>
                                        </g:each>
                                    </select>
                                </div>
                                <div class="col-md-4 mb-3">
                                    <label class="form-label">Capacity Preview</label>
                                    <input type="text" class="form-control" id="capacityPreview" value="3 x 3 = 4 slots/leg" readonly>
                                </div>
                            </div>
                            
                            <div class="d-grid gap-2 d-md-flex justify-content-md-end mt-4">
                                <a href="${createLink(uri: '/member/create')}" class="btn btn-outline-secondary">
                                    <i class="fas fa-forms"></i> Advanced Form
                                </a>
                                <button type="submit" class="btn btn-success">
                                    <i class="fas fa-bolt"></i> Place Member Now
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
            
            <div class="col-lg-4">
                <!-- Placement Info -->
                <div class="card mb-3">
                    <div class="card-header">
                        <i class="fas fa-info-circle"></i> How It Works
                    </div>
                    <div class="card-body">
                        <ol class="mb-0">
                            <li>Enter member details</li>
                            <li>Select a sponsor (or leave empty for root)</li>
                            <li>Configure matrix dimensions</li>
                            <li>Click "Place Member Now"</li>
                            <li>The system will automatically find the best position</li>
                        </ol>
                    </div>
                </div>
                
                <!-- Matrix Templates -->
                <div class="card mb-3">
                    <div class="card-header">
                        <i class="fas fa-clone"></i> Matrix Templates
                    </div>
                    <div class="card-body">
                        <div class="list-group list-group-flush">
                            <button class="list-group-item list-group-item-action template-btn" 
                                    data-width="2" data-height="3">
                                <div class="d-flex justify-content-between">
                                    <span>Small (2x3)</span>
                                    <span class="badge bg-primary">2 slots/leg</span>
                                </div>
                            </button>
                            <button class="list-group-item list-group-item-action template-btn active" 
                                    data-width="3" data-height="3">
                                <div class="d-flex justify-content-between">
                                    <span>Medium (3x3)</span>
                                    <span class="badge bg-primary">4 slots/leg</span>
                                </div>
                            </button>
                            <button class="list-group-item list-group-item-action template-btn" 
                                    data-width="4" data-height="3">
                                <div class="d-flex justify-content-between">
                                    <span>Large (4x3)</span>
                                    <span class="badge bg-primary">6 slots/leg</span>
                                </div>
                            </button>
                            <button class="list-group-item list-group-item-action template-btn" 
                                    data-width="5" data-height="4">
                                <div class="d-flex justify-content-between">
                                    <span>XL (5x4)</span>
                                    <span class="badge bg-primary">16 slots/leg</span>
                                </div>
                            </button>
                        </div>
                    </div>
                </div>
                
                <!-- Recent Placements -->
                <div class="card">
                    <div class="card-header">
                        <i class="fas fa-history"></i> Recent Placements
                    </div>
                    <div class="card-body p-0">
                        <table class="table table-sm mb-0">
                            <thead>
                                <tr>
                                    <th>Member</th>
                                    <th>Position</th>
                                    <th>Depth</th>
                                </tr>
                            </thead>
                            <tbody>
                                <g:each in="${PlacementTransaction?.findAllByOrderByPlacementDateDesc(max: 5)}" var="tx">
                                    <tr>
                                        <td>${tx.member?.userId}</td>
                                        <td><span class="badge bg-info">${tx.placementPosition}</span></td>
                                        <td>${tx.depth}</td>
                                    </tr>
                                </g:each>
                                <g:if test="${!PlacementTransaction?.list()}">
                                    <tr>
                                        <td colspan="3" class="text-center text-muted">No placements yet</td>
                                    </tr>
                                </g:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        // Update capacity preview
        function updateCapacity() {
            const w = parseInt(document.getElementById('matrixWidth').value) || 3;
            const h = parseInt(document.getElementById('matrixHeight').value) || 3;
            const slots = Math.floor((w - 1) * h / 2);
            document.getElementById('capacityPreview').value = `${w} x ${h} = ${slots} slots/leg`;
        }
        
        document.getElementById('matrixWidth').addEventListener('change', updateCapacity);
        document.getElementById('matrixHeight').addEventListener('change', updateCapacity);
        updateCapacity();
        
        // Template buttons
        document.querySelectorAll('.template-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                document.querySelectorAll('.template-btn').forEach(b => b.classList.remove('active'));
                this.classList.add('active');
                document.getElementById('matrixWidth').value = this.dataset.width;
                document.getElementById('matrixHeight').value = this.dataset.height;
                updateCapacity();
            });
        });
        
        // Form submission
        document.getElementById('quickPlacementForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const formData = new FormData(this);
            const data = {};
            formData.forEach((value, key) => data[key] = value);
            
            fetch('${createLink(uri: '/matrix/perform-placement')}', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify(data)
            })
            .then(response => response.json())
            .then(result => {
                const div = document.getElementById('placementResult');
                if (result && result.success) {
                    div.innerHTML = `
                        <div class="alert alert-success">
                            <h5><i class="fas fa-check-circle"></i> Success!</h5>
                            <p>` + result.message + `</p>
                            <hr>
                            <p><strong>Member:</strong> ` + (result.data?.member?.userId || 'N/A') + `</p>
                            <p><strong>Position:</strong> ` + (result.data?.position || 'N/A') + `</p>
                            <p><strong>Direction:</strong> ` + (result.data?.direction || 'N/A') + `</p>
                            <p><strong>Depth:</strong> ` + (result.data?.depth || 'N/A') + `</p>
                            <a href="${createLink(uri: '/member/show/')}` + result.data.member.id + `" class="btn btn-primary btn-sm">View Member</a>
                        </div>`;
                } else {
                    div.innerHTML = '<div class="alert alert-danger"><h5>Error</h5><p>' + (result?.message || 'Unknown error') + '</p></div>';
                }
            })
            .catch(error => {
                document.getElementById('placementResult').innerHTML = 
                    '<div class="alert alert-danger">Error: ' + error.message + '</div>';
            });
        });
    </script>
</body>
</html>