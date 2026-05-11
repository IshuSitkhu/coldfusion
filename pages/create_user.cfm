<?php
include '../auth/auth.cfm';

if (!isAdmin()) {
    die("Access Denied");
}
?>