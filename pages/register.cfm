<!DOCTYPE html>
<html>
<head>
    <title>Register</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>

<body class="bg-light">

<div class="container d-flex justify-content-center align-items-center vh-100">

    <div class="card shadow p-4" style="width: 380px;">
        
        <h3 class="text-center mb-4">Register</h3>

        <input type="text" id="name" class="form-control mb-3" placeholder="Name">

        <input type="email" id="email" class="form-control mb-3" placeholder="Email">

        <input type="password" id="password" class="form-control mb-3" placeholder="Password">

        <button onclick="register()" class="btn btn-success w-100 mb-2">Register</button>

        <div class="text-center">
            <small>Already have an account? 
                <a href="login.cfm">Login</a>
            </small>
        </div>

    </div>

</div>

<script>
function register() {

    $.ajax({
        url: "../api/register.cfm",
        method: "POST",
        data: {
            name: $("#name").val(),
            email: $("#email").val(),
            password: $("#password").val()
        },
        dataType: "json",
        success: function(res) {
            if (res.status === "success") {
                Swal.fire("Success", "Registered successfully", "success");
                window.location.href = "login.cfm";
            } else {
                Swal.fire("Error", res.message, "error");
            }
        }
    });

}
</script>

</body>
</html>