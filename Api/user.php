<?php
$servername = "localhost";
$username = "id21923587_handworkpj";
$password = "123Mm@#8";
$dbname = "id21923587_handwork";
$table = "Accounts";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check Connection
if ($conn->connect_error) {
    die("Connection Failed: " . $conn->connect_error);
    return;
}

if (isset($_POST["action"])) {
    $action = $_POST["action"];
} else {
    die("No action specified");
}

if ("CREATE_TABLE" == $action) {
    $sql = "CREATE TABLE IF NOT EXISTS $table
        (id INT(10) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    firstName VARCHAR(30) NOT NULL,
    lastName VARCHAR(30) NOT NULL,
    email VARCHAR(50) NOT NULL,
    nationalid VARCHAR(14) NOT NULL,
    passwordd TEXT(100) NOT NULL,
    user_type VARCHAR(10) NOT NULL,
    image TEXT NOT NULL,
    status TINYINT(1) DEFAULT 1
        )";

    if ($conn->query($sql) === TRUE) {
        echo "success";
    } else {
        echo "error";
    }
}

if ("ADD_USER" == $action) {
    $firstName = $_POST["first_name"];
    $lastName = $_POST["last_name"];
    $email = $_POST["email"];
    $nationalid = $_POST["nationalid"];
    $password = $_POST["password"];
    $user_type = $_POST["user_type"];
    $image = $_POST["image"];

    $image_name = uniqid() . '.png';
    $image_path = 'images/' . $image_name;
    $file_put_contents_result = file_put_contents($image_path, base64_decode($image));

    if (!$file_put_contents_result) {
        die("Failed to save image");
    }

    if ($file_put_contents_result === false) {
        echo "Failed to save image";
    } else {
        $sql = "INSERT INTO $table (firstName, lastName, email, nationalid, passwordd, user_type, image)
        VALUES ('$firstName', '$lastName', '$email', '$nationalid', '$password', '$user_type', '$image_name')";
        if ($conn->query($sql) === TRUE) {
            echo "success";
        } else {
            echo "error";
        }
    }

    $conn->close();
    return;
}


if ("CHAKE_USER" == $action) {
    $nationalid = $_POST["nationalid"];
    $password = $_POST["password"];

    if (empty($nationalid) || empty($password)) {
        die("Please provide both National ID and Password");
    }

    $sql = "SELECT * FROM $table WHERE nationalid='$nationalid' AND passwordd='$password' AND status='1'";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $user_type = $row["user_type"];
        echo json_encode(array("status" => "success", "user_type" => $user_type));
    } else {
        echo json_encode(array("status" => "failure"));
    }

    $conn->close();
}


if ("GIT_INFO" == $action) {
    $nationalid = $_POST["nationalid"];
    $password = $_POST["password"];

    if (empty($nationalid) || empty($password)) {
        die("Please provide both National ID and Password");
    }
    $db_data = array();
    $sql = "SELECT * FROM $table WHERE nationalid='$nationalid' AND passwordd='$password' AND status='1'";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $row['image'] = base64_encode(file_get_contents('images/' . $row['image']));
            $db_data[] = $row;
        }
        echo json_encode($db_data);
    } else {
        echo json_encode([]);
    }
    $conn->close();
    return;
}

if ("EDIT_ACC" == $action) {
    $nationalid = $_POST["nationalid"];
    $new_password = $_POST["new_password"];

    if (empty($nationalid) || empty($new_password)) {
        die("Please provide both National ID and New Password");
    }

    $sql = "UPDATE $table SET passwordd='$new_password' WHERE nationalid='$nationalid'";
    if ($conn->query($sql) === TRUE) {
        echo "success";
    } else {
        echo "error: " . $conn->error;
    }

    $conn->close();
}

if ("CHECK_NATIONAL_ID" == $action) {
    $nationalid = $_POST["nationalid"];

    $sql = "SELECT * FROM $table WHERE nationalid='$nationalid' AND status='1'";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        echo "exists";
    } else {
        echo "not_exists";
    }

    $conn->close();
    return;
}

if ("DISABLE_USER" == $action) {
    $nationalid = $_POST["nationalid"];
    $email = $_POST["email"];
    $password = $_POST["password"];

    if (empty($nationalid) || empty($email) || empty($password)) {
        die("Please provide National ID, Email, and Password");
    }

    // Check if the provided credentials are correct
    $sql = "SELECT * FROM $table WHERE nationalid='$nationalid' AND email='$email' AND passwordd='$password' AND status='1'";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        // Disable the account
        $sql = "UPDATE $table SET status='0' WHERE nationalid='$nationalid'";
        if ($conn->query($sql) === TRUE) {
            echo "success";
        } else {
            echo "error";
        }
    } else {
        echo "Invalid credentials";
    }

    $conn->close();
    return;
}
?>
