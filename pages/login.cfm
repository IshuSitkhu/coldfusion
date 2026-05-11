<!DOCTYPE html>
<html>
<head>
    <title>Login</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>

<body class="bg-light">

<div class="container d-flex justify-content-center align-items-center vh-100">
    
    <div class="card shadow p-4" style="width: 380px;">
        
        <h3 class="text-center mb-4">Login</h3>

        <input type="email" id="email" class="form-control mb-3" placeholder="Email">

        <input type="password" id="password" class="form-control mb-3" placeholder="Password">

        <button onclick="login()" class="btn btn-primary w-100 mb-2">Login</button>

        <div class="text-center">
            <small>Dont have an account? 
                <a href="register.cfm">Register Now!</a>
            </small>
        </div>
    </div>

</div>

<script>
function login() {

    let email = $("#email").val();
    let password = $("#password").val();

    if (email == "" || password == "") {
        Swal.fire("Error", "All fields required", "error");
        return;
    }

    $.ajax({
        url: "../api/login.cfm",
        method: "POST",
        data: { email, password },
        dataType: "json",
        success: function(res) {

            if (res.status === "success") {
                window.location.href = res.redirect;
            } else {
                Swal.fire("Error", res.message, "error");
            }
        }
    });
}
</script>

</body>
</html>