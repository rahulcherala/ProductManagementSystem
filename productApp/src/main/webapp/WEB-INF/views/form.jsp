<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<h3>Add / Edit Product</h3>

<form id="productForm" method="post">
    <input type="hidden" name="id" value="0"/>
    <input type="hidden" name="formToken" value=""/>
    <div class="form-error" style="color:red;"></div>

    <label>Name:</label>
    <input type="text" name="name" data-error-target="nameError"/>
    <div id="nameError" style="color:red;"></div><br/>

    <label>Price:</label>
    <input type="number" name="price" data-error-target="priceError"/>
    <div id="priceError" style="color:red;"></div><br/>

    <label>Quantity:</label>
    <input type="number" name="quantity" data-error-target="quantityError"/>
    <div id="quantityError" style="color:red;"></div><br/>

    <button type="submit">Save</button>
    <button type="button" onclick="$('#modalForm').hide()">Cancel</button>
</form>

<script>
function validateForm(form) {
    let valid = true;
    form.find(".form-error").text("");
    $("#nameError,#priceError,#quantityError").text("");

    let name = form.find("[name='name']").val().trim();
    let price = form.find("[name='price']").val().trim();
    let qty = form.find("[name='quantity']").val().trim();

    if (name === "") { $("#nameError").text("Please enter product name"); valid = false; }
    if (price === "" || Number(price) <= 0) { $("#priceError").text("Price must be > 0"); valid = false; }
    if (qty === "" || Number(qty) <= 0) { $("#quantityError").text("Quantity must be > 0"); valid = false; }

    return valid;
}

function bindAjaxForm(formSelector, options = {}) {
    var ctx = options.contextPath || "";
    $(formSelector).on("submit", function(e) {
        e.preventDefault();
        var form = $(this);
        if (!validateForm(form)) return;

        $.ajax({
            url: ctx + "/product/save",
            method: "POST",
            data: form.serialize(),
            dataType: "json",
            headers: { "X-Requested-With": "XMLHttpRequest" },
            success: function(res) {
                if (res.success) {
                    if (options.onSuccess) options.onSuccess(res);
                }
            },
            error: function(xhr) {
                var res = xhr.responseJSON;
                if (res && res.formError) {
                    form.find(".form-error").text(res.formError);
                } else if (res && res.errors) {
                    Object.keys(res.errors).forEach(f => {
                        $("#" + f + "Error").text(res.errors[f]);
                    });
                } else {
                    form.find(".form-error").text("Unexpected error occurred.");
                }
            }
        });
    });
}
</script>
