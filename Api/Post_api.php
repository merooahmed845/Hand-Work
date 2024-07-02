<?php

$servername = "localhost";
$username = "id21923587_handworkpj";
$password = "123Mm@#8";
$dbname = "id21923587_handwork";
$table_posts = "post";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection Failed: " . $conn->connect_error);
    return;
}

// Check if 'action' key exists in $_POST
if (isset($_POST["action"])) {
    $action = $_POST["action"];
} else {
    echo "Action not set!";
    return;
}

// If the app sends an action to create the table...
if ("CREATE_TABLE" == $action) {
    $sql_accounts = "CREATE TABLE IF NOT EXISTS $table_accounts
        ( id INT(10) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        firstName VARCHAR(30) NOT NULL,
        lastName VARCHAR(30) NOT NULL,
        email VARCHAR(50) NOT NULL,
        nationalid VARCHAR(14) NOT NULL,
        passwordd TEXT(100) NOT NULL,
        user_type VARCHAR(10) NOT NULL,
        image TEXT NOT NULL,
        )";

    $sql_posts = "CREATE TABLE IF NOT EXISTS $table_posts
        ( id INT(10) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        username VARCHAR(30) NOT NULL,
        nationalid VARCHAR(30) NOT NULL,
        phonenumber VARCHAR(30) NOT NULL,
        city VARCHAR(30) NOT NULL,
        posttitle VARCHAR(30) NOT NULL,
        posttext TEXT(500) NOT NULL,
        image TEXT NOT NULL,
        FOREIGN KEY (nationalid) REFERENCES $table_accounts(nationalid)
        )";

    if ($conn->query($sql_accounts) === TRUE && $conn->query($sql_posts) === TRUE) {
        echo "success";
    } else {
        echo "error";
    }
}

// These action to add post to table
if ("ADD_POST" == $action) {
    $username = $_POST["user_name"];
    $nationalid = $_POST["national_id"];
    $phonenumber = $_POST["phone_number"];
    $city = $_POST["city"];
    $title = $_POST["post_title"];
    $posttext = $_POST["post_text"];
    $image = $_POST["image"];

    // Check if the nationalid exists in the Accounts table and is active
    $sql_check = "SELECT * FROM $table_accounts WHERE nationalid='$nationalid' AND status=1";
    $result_check = $conn->query($sql_check);

    if ($result_check->num_rows > 0) {
        $image_name = uniqid() . '.png';
        $image_path = 'images/' . $image_name;
        $file_put_contents_result = file_put_contents($image_path, base64_decode($image));

        if ($file_put_contents_result === false) {
            echo "Failed to save image";
        } else {
            $sql = "INSERT INTO $table_posts (username, nationalid, phonenumber, city, posttitle, posttext, image)
                    VALUES ('$username', '$nationalid', '$phonenumber', '$city', '$title', '$posttext', '$image_name')";
            if ($conn->query($sql) === TRUE) {
                echo "success";
            } else {
                echo "error";
            }
        }
    } else {
        echo "Invalid National ID or account is inactive";
    }

    $conn->close();
    return;
}

// Get all posts records from the database
if ("GET_ALL" == $action) {
    $db_data = array();
    $sql = "SELECT id, username, nationalid, phonenumber, city, posttitle, posttext, image FROM $table_posts ORDER BY id DESC";
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


if ("DELETE_POST" == $action) {
    $post_id = $_POST['POST_ID'];
    $sql = "DELETE FROM $table_posts WHERE id = $post_id";
    if ($conn->query($sql) === TRUE) {
        echo "success";
    } else {
        echo "error";
    }

    $conn->close();
    return;
}
?>
