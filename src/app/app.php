<?php

class Application
{
    private $pdo;

    public function __construct($host, $db, $user, $pass, $charset)
    {
        $dsn = "mysql:host=$host;dbname=$db;charset=$charset";
        $options = [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ];

        try {
            $this->pdo = new PDO($dsn, $user, $pass, $options);
        } catch (\PDOException $e) {
            $this->err($e);
        }
    }

    private function err($e)
    {
        $timestamp = date('Y-m-d H:i:s');
        $exceptionClass = get_class($e);
        $errorMessage = sprintf(
            "[%s] ERROR: Exception [%s], Code [%s], Message: %s, File: %s, Line: %s",
            $timestamp,
            $exceptionClass,
            $e->getCode(),
            $e->getMessage(),
            $e->getFile(),
            $e->getLine()
        );

        error_log($errorMessage, 3, 'php://stderr');
    }

    private function renderTemplate($filename, array $assignData = [])
    {
        $escapedAssignData = $this->escape($assignData);
        if ($escapedAssignData) {
            extract($escapedAssignData);
        }

        include __DIR__ . '/template/'.$filename.'.tpl.php';
    }

    private function escape($data)
    {
        if (is_array($data)) {
            return array_map([$this, 'escape'], $data);
        }
        return htmlspecialchars($data, ENT_QUOTES, 'UTF-8');
    }

    private function getDBVersion()
    {
        $defaultVersion = 'N/A';

        if (!isset($this->pdo)) {
            return $defaultVersion;
        }

        try {
            $query = $this->pdo->query("SELECT VERSION()");
            return $query->fetchColumn() ?: $defaultVersion;
        } catch (\PDOException $e) {
            $this->err($e);
        }

        return $defaultVersion;
    }

    public function execute()
    {
        $this->renderTemplate('index', [
            'message'     => 'Hello! Docker Compose!',
            'php_version' => phpversion(),
            'db_version'  => $this->getDBVersion(),
        ]);
    }
}

$app = new Application(
    $_ENV['DB_HOST']    ?? 'localhost',
    $_ENV['DB_NAME']    ?? 'mysql',
    $_ENV['DB_USER']    ?? 'root',
    $_ENV['DB_PASS']    ?? 'root',
    $_ENV['DB_CHARSET'] ?? 'utf8mb4'
);

return $app;
