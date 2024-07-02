<?php
$servername = "localhost";
$username = "id21923587_handworkpj";
$password = "123Mm@#8";
$dbname = "id21923587_handwork";
$table_accounts = "Accounts";
$table_posts = "post";
$table_feedback = "Feedback";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check Connection
if ($conn->connect_error) {
    die("Connection Failed: " . $conn->connect_error);
    return;
}

// Check if 'action' key exists in $_POST
if (isset($_POST["action"])) {
    $action = $_POST["action"];
} else {
    die("No action specified");
}

// If the app sends an action to create the Accounts table...
if ("CREATE_TABLES_Accounts" == $action) {
    $sql_accounts = "CREATE TABLE IF NOT EXISTS $table_accounts
        (id INT(10) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        firstName VARCHAR(30) NOT NULL,
        lastName VARCHAR(30) NOT NULL,
        email VARCHAR(50) NOT NULL,
        nationalid VARCHAR(14) NOT NULL UNIQUE,
        passwordd TEXT(100) NOT NULL,
        user_type VARCHAR(10) NOT NULL,
        image TEXT NOT NULL,
        status TINYINT(1) DEFAULT 1
        )";

    if ($conn->query($sql_accounts) === TRUE) {
        echo "success";
    } else {
        echo "error: " . $conn->error;
    }
}

// If the app sends an action to create the Posts table...
if ("CREATE_TABLES_Posts" == $action) {
    $sql_posts = "CREATE TABLE IF NOT EXISTS $table_posts
        (id INT(10) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        username VARCHAR(30) NOT NULL,
        nationalid VARCHAR(14) NOT NULL,
        phonenumber VARCHAR(30) NOT NULL,
        city VARCHAR(30) NOT NULL,
        posttitle VARCHAR(30) NOT NULL,
        posttext TEXT(500) NOT NULL,
        image TEXT NOT NULL,
        FOREIGN KEY (nationalid) REFERENCES $table_accounts(nationalid)
        )";

    if ($conn->query($sql_posts) === TRUE) {
        echo "success";
    } else {
        echo "error: " . $conn->error;
    }
}

if ("CREATE_TABLES_Feedback" == $action) {
    $sql_feedback = "CREATE TABLE IF NOT EXISTS $table_feedback (
        id INT(10) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        post_id INT(10) UNSIGNED NOT NULL,
        name VARCHAR(255) NOT NULL,
        feedback_text TEXT NOT NULL,
        FOREIGN KEY (post_id) REFERENCES $table_posts(id)
    )";

    if ($conn->query($sql_feedback) === TRUE) {
        echo "success";
    } else {
        echo "error: " . $conn->error;
    }
}


if ("ADD_FEEDBACK" == $action) {
    $post_id = $_POST['post_id'];
    $name = $_POST['name'];
    $feedback_text = $_POST['feedbacktext'];

    $sql = "INSERT INTO $table_feedback (post_id, name ,feedback_text ) VALUES ('$post_id', '$name', '$feedback_text')";

    if ($conn->query($sql) === TRUE) {
        echo "success";
    } else {
        echo "error: " . $conn->error;
    }
}




// Action to add user
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

    $sql = "INSERT INTO $table_accounts (firstName, lastName, email, nationalid, passwordd, user_type, image)
            VALUES ('$firstName', '$lastName', '$email', '$nationalid', '$password', '$user_type', '$image_name')";

    if ($conn->query($sql) === TRUE) {
        echo "success";
    } else {
        echo "error: " . $conn->error;
    }
}


// Action to add post
if ("ADD_POST" == $action) {
    $username = $_POST["user_name"];
    $nationalid = $_POST["national_id"];
    $phonenumber = $_POST["phone_number"];
    $city = $_POST["city"];
    $title = $_POST["post_title"];
    $posttext = $_POST["post_text"];
    $image = $_POST["image"];

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
                echo "error: " . $conn->error;
            }
        }
    } else {
        echo "Invalid National ID or account is inactive";
    }
}


// Check user
if ("CHAKE_USER" == $action) {
    $nationalid = $_POST["nationalid"];
    $password = $_POST["password"];

    if (empty($nationalid) || empty($password)) {
        die("Please provide both National ID and Password");
    }

    $sql = "SELECT * FROM $table_accounts WHERE nationalid='$nationalid' AND passwordd='$password' AND status='1'";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $user_type = $row["user_type"];
        echo json_encode(array("status" => "success", "user_type" => $user_type));
    } else {
        echo json_encode(array("status" => "failure"));
    }
}

// Get user info
if ("GIT_INFO" == $action) {
    $nationalid = $_POST["nationalid"];
    $password = $_POST["password"];

    if (empty($nationalid) || empty($password)) {
        die("Please provide both National ID and Password");
    }
    $db_data = array();
    $sql = "SELECT * FROM $table_accounts WHERE nationalid='$nationalid' AND passwordd='$password' AND status='1'";
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
}



// Edit account
if ("EDIT_ACC" == $action) {
    $nationalid = $_POST["nationalid"];
    $new_password = $_POST["new_password"];

    if (empty($nationalid) || empty($new_password)) {
        die("Please provide both National ID and New Password");
    }

    $sql = "UPDATE $table_accounts SET passwordd='$new_password' WHERE nationalid='$nationalid'";
    if ($conn->query($sql) === TRUE) {
        echo "success";
    } else {
        echo "error: " . $conn->error;
    }
}

// Check national ID
if ("CHECK_NATIONAL_ID" == $action) {
    $nationalid = $_POST["nationalid"];

    $sql = "SELECT * FROM $table_accounts WHERE nationalid='$nationalid' AND status='1'";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        echo "exists";
    } else {
        echo "not_exists";
    }
}

// Disable user
if ("DISABLE_USER" == $action) {
    $nationalid = $_POST["nationalid"];
    $email = $_POST["email"];
    $password = $_POST["password"];

    if (empty($nationalid) || empty($email) || empty($password)) {
        die("Please provide National ID, Email, and Password");
    }

    $sql = "SELECT * FROM $table_accounts WHERE nationalid='$nationalid' AND email='$email' AND passwordd='$password' AND status='1'";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $sql = "UPDATE $table_accounts SET status='0' WHERE nationalid='$nationalid'";
        if ($conn->query($sql) === TRUE) {
            echo "success";
        } else {
            echo "error: " . $conn->error;
        }
    } else {
        echo "Invalid credentials";
    }
}

// Get all posts
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
}

// Delete post
if ("DELETE_POST" == $action) {
    $post_id = $_POST['POST_ID'];
    $sql = "DELETE FROM $table_posts WHERE id = $post_id";
    if ($conn->query($sql) === TRUE) {
        echo "success";
    } else {
        echo "error: " . $conn->error;
    }
}


if ("GET_FEEDBACK" == $action) {
    $db_data = array();
    $sql = "SELECT id, post_id, name, feedback_text FROM $table_feedback ORDER BY id DESC";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $db_data[] = $row;
        }
        echo json_encode($db_data);
    } else {
        echo json_encode([]);
    }
}

if ("CHAKE_FORGET" == $action) {
    $nationalid = $_POST["nationalid"];
    $email = $_POST["email"];

    if (empty($nationalid) || empty($email)) {
        die("Please provide both National ID and Password");
    }

    $sql = "SELECT * FROM $table_accounts WHERE nationalid='$nationalid' AND email='$email' AND status='1'";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $user_type = $row["user_type"];
        echo json_encode(array("status" => "success", "user_type" => $user_type));
    } else {
        echo json_encode(array("status" => "failure"));
    }
}
$conn->close();
?>
