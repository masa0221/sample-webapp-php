<!doctype html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <script src="https://cdn.tailwindcss.com/3.0.0"></script>
</head>
<body class="bg-gray-50 flex items-center justify-center min-h-screen">
  <div class="bg-white p-10 rounded-lg shadow-lg">
    <h1 class="text-4xl font-bold underline text-gray-900"><?php echo $message; ?></h1>
    <p class="mt-4 text-gray-600">PHP version: <?php echo $php_version; ?></p>
    <p class="mt-4 text-gray-600">MySQL version: <?php echo $db_version; ?></p>
  </div>
</body>
</html>
