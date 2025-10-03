<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isELIgnored="false" %>
<!DOCTYPE html>
<html>
<head>
    <title>Product Management SPA</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body class="container mt-4">

<h2 class="mb-4">Product Management</h2>

<!-- Product Table -->
<div id="productTableContainer"></div>

<!-- Pagination -->
<nav>
    <ul class="pagination" id="pagination"></ul>
</nav>

<!-- Add Product Button -->
<button class="btn btn-primary mb-3" id="addBtn">Add Product</button>

<!-- Modal for Add/Edit -->
<div class="modal fade" id="productModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form id="productForm">
                <div class="modal-header">
                    <h5 class="modal-title" id="modalTitle">Add Product</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div id="formError" class="text-danger mb-2"></div>
                    <input type="hidden" name="id" id="productId"/>
                    <input type="hidden" name="formToken" id="formToken"/>

                    <div class="mb-3">
                        <label class="form-label">Name</label>
                        <input type="text" name="name" id="name" class="form-control"/>
                        <div id="nameError" class="text-danger small"></div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Price</label>
                        <input type="number" name="price" id="price" class="form-control"/>
                        <div id="priceError" class="text-danger small"></div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Quantity</label>
                        <input type="number" name="quantity" id="quantity" class="form-control"/>
                        <div id="quantityError" class="text-danger small"></div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="submit" class="btn btn-success">Save</button>
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
let currentPage = 1;
let totalPages = 1;
let startPage = 1;
let endPage = 1;
const ctx = "${pageContext.request.contextPath}";

function loadProducts(page = 1) {
    console.log("Loading page:", page);

    $.ajax({
        url: ctx + "/product/list",
        method: "GET",
        data: { page },
        dataType: "json",
        success: function(data) {
            console.log("Full Data Object:", data);

            let html = `<table class="table table-bordered">
                            <thead>
                                <tr>
                                    <th>ID</th><th>Name</th><th>Price</th><th>Quantity</th><th>Actions</th>
                                </tr>
                            </thead><tbody>`;

            // 🔹 Ensure products is an array
            let products = Array.isArray(data.products) ? data.products : Object.values(data.products);

            products.forEach(p => {
                console.log("Row data:", p);
                console.log(Object.keys(p));
                console.log("ID:", p.id, "Name:", p.name, "Price:", p.price, "Qty:", p.quantity);

                
                html += `
                    <tr>
                        <td>\${p.id}</td>
                        <td>\${p.name}</td>
                        <td>\${p.price}</td>
                        <td>\${p.quantity}</td>
                        <td>
                            <button class="btn btn-sm btn-warning" onclick="editProduct(\${p.id})">Edit</button>
                            <button class="btn btn-sm btn-danger" onclick="deleteProduct(\${p.id})">Delete</button>
                        </td>
                    </tr>`;
            });

            html += "</tbody></table>";
            console.log("Generated HTML:", html);

            $("#productTableContainer").html(html);

            currentPage = data.currentPage;
            totalPages = data.totalPages;
            startPage = data.startPage;
            endPage = data.endPage;

            renderPagination();
        },
        error: function(xhr) {
            console.error("Error loading products:", xhr.responseText);
            $("#productTableContainer").html("<p class='text-danger'>Failed to load products.</p>");
        }
    });
}



// Render enhanced pagination
function renderPagination() {
    let html = "";

    const prevPage = Math.max(1, currentPage - 1);
    const nextPage = Math.min(totalPages, currentPage + 1);

    // Prev
    html += `<li class="page-item \${currentPage == 1 ? "disabled" : ""}">
                <a class="page-link" href="#" onclick="loadProducts(\${prevPage}); return false;">Prev</a>
             </li>`;

    // Page numbers
    for (let i = startPage; i <= endPage; i++) {
        html += `<li class="page-item \${i == currentPage ? "active" : ""}">
                    <a class="page-link" href="#" onclick="loadProducts(\${i}); return false;">\${i}</a>
                 </li>`;
    }

    // Next
    html += `<li class="page-item \${currentPage == totalPages ? "disabled" : ""}">
                <a class="page-link" href="#" onclick="loadProducts(\${nextPage}); return false;">Next</a>
             </li>`;

    $("#pagination").html(html);
}



// Open Add modal
$("#addBtn").click(function() {
    $.get(ctx + "/product/form", function(res) {
        $("#modalTitle").text("Add Product");
        $("#productId").val(0);
        $("#name, #price, #quantity").val("");
        $("#formToken").val(res.formToken);
        clearErrors();
        new bootstrap.Modal(document.getElementById("productModal")).show();
    });
});

// Open Edit modal
function editProduct(id) {
    $.get(ctx + "/product/" + id, function(p) {
        $.get(ctx + "/product/form", function(res) {
            $("#modalTitle").text("Edit Product");
            $("#productId").val(p.id);
            $("#name").val(p.name);
            $("#price").val(p.price);
            $("#quantity").val(p.quantity);
            $("#formToken").val(res.formToken);
            clearErrors();
            new bootstrap.Modal(document.getElementById("productModal")).show();
        });
    });
}

// Client-side validation
function validateForm() {
    clearErrors();
    let valid = true;
    const name = $("#name").val().trim();
    const price = parseFloat($("#price").val());
    const quantity = parseInt($("#quantity").val());

    if (!name) { $("#nameError").text("Please enter product name"); valid = false; }
    if (isNaN(price) || price <= 0) { $("#priceError").text("Price must be > 0"); valid = false; }
    if (isNaN(quantity) || quantity <= 0) { $("#quantityError").text("Quantity must be > 0"); valid = false; }

    return valid;
}

// Save product
$("#productForm").submit(function(e) {
    e.preventDefault();
    if (!validateForm()) return;

    const $submitBtn = $(this).find("button[type='submit']");

    // If already disabled, prevent double submission
    if ($submitBtn.prop("disabled")) return;

    $submitBtn.prop("disabled", true); // disable immediately

    $.ajax({
        url: ctx + "/product/save",
        method: "POST",
        data: $(this).serialize(),
        success: function() {
            // close modal after short delay if needed
            setTimeout(() => {
                bootstrap.Modal.getInstance(document.getElementById("productModal")).hide();
                $submitBtn.prop("disabled", false); // re-enable when modal hides
            }, 1000); // reduce delay for better UX

            loadProducts(currentPage);
        },
        error: function(xhr) {
            const res = xhr.responseJSON;
            if (res) {
                if (res.formError) $("#formError").text(res.formError);
                if (res.errors) {
                    if (res.errors.name) $("#nameError").text(res.errors.name);
                    if (res.errors.price) $("#priceError").text(res.errors.price);
                    if (res.errors.quantity) $("#quantityError").text(res.errors.quantity);
                }
            }
        }
    });
});

// Extra: re-enable button whenever modal is closed manually
$('#productModal').on('hidden.bs.modal', function () {
    $(this).find("button[type='submit']").prop("disabled", false);
});


// Delete product
function deleteProduct(id) {
    if (!confirm("Are you sure?")) return;
    $.ajax({
        url: ctx + "/product/" + id,
        method: "DELETE",
        success: function() { loadProducts(currentPage); }
    });
}

// Clear errors
function clearErrors() {
    $("#formError, #nameError, #priceError, #quantityError").text("");
}

// Initialize
$(function() { loadProducts(); });
</script>
</body>
</html>
