// Désactiver les erreurs deprecated pour PHP 8.2
error_reporting(E_ALL & ~E_DEPRECATED & ~E_NOTICE);
ini_set('display_errors', 0);
header('Cache-Control: no-cache, must-revalidate');
header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
header('Content-Type: application/json; charset=utf-8');

$apiKey = getenv('PRESTASHOP_API_KEY') ?: 'WD4YUTKV1136122LWTI64EQCMXAIM99S';
$baseApiUrl = 'http://localhost:8080/prestashop/api/';
$logFile = __DIR__ . '/api_proxy.log';

$allowedResources = [
    'addresses', 'attachments', 'carriers', 'cart_rules', 'carts', 'categories', 'combinations',
    'configurations', 'contacts', 'content_management_system', 'countries', 'currencies',
    'customer_messages', 'customer_threads', 'customers', 'customizations', 'deliveries',
    'employees', 'groups', 'guests', 'image_types', 'images', 'kbsellercategories',
    'kbsellercrequests', 'kbsellerearnings', 'kbsellermenus', 'kbsellerorderdetails',
    'kbsellerproductreviews', 'kbsellerproducts', 'kbsellerreviews', 'kbsellers',
    'kbsellershippings', 'kbsellertransactions', 'languages', 'manufacturers', 'messages',
    'order_carriers', 'order_cart_rules', 'order_details', 'order_histories', 'order_invoices',
    'order_payments', 'order_slip', 'order_states', 'orders', 'price_ranges',
    'product_customization_fields', 'product_feature_values', 'product_features',
    'product_option_values', 'product_options', 'product_suppliers', 'products', 'search',
    'shop_groups', 'shop_urls', 'shops', 'specific_price_rules', 'specific_prices', 'states',
    'stock_availables', 'stock_movement_reasons', 'stock_movements', 'stocks', 'stores',
    'suppliers', 'supply_order_details', 'supply_order_histories', 'supply_order_receipt_histories',
    'supply_order_states', 'supply_orders', 'tags', 'tax_rule_groups', 'tax_rules', 'taxes',
    'translated_configurations', 'warehouse_product_locations', 'warehouses', 'weight_ranges', 'zones'
];$allowedMethods = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'HEAD'];

function logMessage($message) {
    global $logFile;
    $timestamp = date('Y-m-d H:i:s');
    file_put_contents($logFile, "[$timestamp] $message\n", FILE_APPEND);
}

function arrayToXml($data, $rootElement = 'root', $xml = null) {
    if ($xml === null) {
        $xml = new SimpleXMLElement("<$rootElement/>");
    }
    foreach ($data as $key => $value) {
        if (is_numeric($key)) {
            $key = 'item'; // XML tags cannot be numeric
        }
        if (is_array($value)) {
            arrayToXml($value, $key, $xml->addChild($key));
        } else {
            $xml->addChild($key, htmlspecialchars($value));
        }
    }
    return $xml->asXML();
}

// -------------------- LOGIN --------------------
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$uri = str_replace('/prestashop/proxy.php', '', $uri); // adapte si proxy.php est ailleurs
if ($uri === '/login' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $json = json_decode(file_get_contents('php://input'), true);
    if (!$json || !isset($json['email'], $json['passwd'])) {
        http_response_code(400);
        echo json_encode(['error' => 'email et passwd requis']);
        logMessage('Missing email or passwd in /login');
        exit;
    }

    $email = $json['email'];
    $passwd = $json['passwd'];

    $url = $baseApiUrl . 'customers?output_format=JSON&filter[email]=' . urlencode($email);
    $ch = curl_init($url);
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => ['Authorization: Basic ' . base64_encode($apiKey . ':')],
        CURLOPT_SSL_VERIFYPEER => false,
    ]);
    $response = curl_exec($ch);
    $status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $curlError = curl_error($ch);
    curl_close($ch);

    if ($response === false || $status >= 400) {
        http_response_code($status ?: 500);
        echo json_encode(['error' => $response ? 'Erreur API' : 'Erreur cURL : ' . $curlError]);
        logMessage('Login error: ' . ($curlError ?: $response));
        exit;
    }

    $data = json_decode($response, true);
    if (!$data || !isset($data['customers'][0])) {
        http_response_code(401);
        echo json_encode(['error' => 'Utilisateur non trouvé']);
        logMessage('User not found: ' . $email);
        exit;
    }

    $id = $data['customers'][0]['id'];
    $xmlUrl = $baseApiUrl . "customers/$id";
    $ch = curl_init($xmlUrl);
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => ['Authorization: Basic ' . base64_encode($apiKey . ':')],
        CURLOPT_SSL_VERIFYPEER => false,
    ]);
    $xml = curl_exec($ch);
    $status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $curlError = curl_error($ch);
    curl_close($ch);

    if ($xml === false || $status >= 400) {
        http_response_code($status ?: 500);
        echo json_encode(['error' => $xml ? 'Erreur API' : 'Erreur cURL : ' . $curlError]);
        logMessage('Login customer details error: ' . ($curlError ?: $xml));
        exit;
    }

    $xmlObj = simplexml_load_string($xml);
    $customer = $xmlObj->customer;
    $storedHash = trim((string) $customer->passwd); // Nettoie des espaces ou retours chariot éventuels

    if (!password_verify($passwd, $storedHash)) {
        http_response_code(401);
        echo json_encode(['error' => 'Mot de passe invalide']);
        logMessage('Invalid password for: ' . $email);
        exit;
    }

    echo json_encode([
    'success' => true,
    'customer' => [
        'id' => (string)$customer->id,
        'firstname' => (string)$customer->firstname,
        'lastname' => (string)$customer->lastname,
        'email' => (string)$customer->email,
        'phone' => (string)($customer->phone ?? ''),
        'company' => (string)($customer->company ?? ''),
        'active' => (string)$customer->active,
        'date_add' => (string)$customer->date_add,
        'date_upd' => (string)$customer->date_upd,
    ]
]);

    logMessage('Login successful for: ' . $email);
    exit;
}

// -------------------- SIGNUP --------------------
if ($uri === '/signup' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $json = json_decode(file_get_contents('php://input'), true);
    if (!$json || !isset($json['customer'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Objet "customer" requis']);
        logMessage('Missing customer object in /signup');
        exit;
    }

    $customer = $json['customer'];
    foreach (['firstname', 'lastname', 'email', 'passwd'] as $field) {
        if (empty($customer[$field])) {
            http_response_code(400);
            echo json_encode(['error' => "Champ requis: $field"]);
            logMessage("Missing required field in /signup: $field");
            exit;
        }
    }

    // Ne surtout pas hasher ici, laisser PrestaShop faire
    $plainPassword = $customer['passwd'];

    // Obtenir le schéma vierge (blank schema)
    $ch = curl_init($baseApiUrl . 'customers?schema=blank');
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => [
            'Authorization: Basic ' . base64_encode($apiKey . ':'),
            'Accept: application/xml',
        ],
        CURLOPT_SSL_VERIFYPEER => false,
    ]);
    $blankXml = curl_exec($ch);
    $status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $curlError = curl_error($ch);
    curl_close($ch);

    if (!$blankXml || $status >= 400) {
        http_response_code(500);
        echo json_encode(['error' => 'Erreur récupération schema blank']);
        logMessage('Signup: erreur récupération schema blank: ' . $curlError);
        exit;
    }

    $xml = simplexml_load_string($blankXml);
    if (!$xml) {
        http_response_code(500);
        echo json_encode(['error' => 'Erreur parsing XML blank']);
        logMessage('Signup: parsing XML blank failed');
        exit;
    }

    // Remplir le schéma avec les données fournies
    foreach ($customer as $key => $value) {
        if (isset($xml->customer->$key)) {
            $xml->customer->$key = $value;
        }
    }

    // Valeurs par défaut
    $xml->customer->active = $customer['active'] ?? 1;
    $xml->customer->id_default_group = $customer['id_default_group'] ?? 3;

    // Envoyer à l'API PrestaShop
    $ch = curl_init($baseApiUrl . 'customers');
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_CUSTOMREQUEST => 'POST',
        CURLOPT_HTTPHEADER => [
            'Authorization: Basic ' . base64_encode($apiKey . ':'),
            'Content-Type: application/xml',
            'Accept: application/xml'
        ],
        CURLOPT_POSTFIELDS => $xml->asXML(),
        CURLOPT_SSL_VERIFYPEER => false,
    ]);
    $response = curl_exec($ch);
    $status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $curlError = curl_error($ch);
    curl_close($ch);

    if ($response === false || $status >= 400) {
        http_response_code($status ?: 500);
        echo json_encode(['error' => 'Erreur API PrestaShop', 'details' => $response ?: $curlError]);
        logMessage('Signup error: ' . ($curlError ?: $response));
        exit;
    }

    echo json_encode(['success' => true]);
    logMessage('Signup success: ' . $customer['email']);
    exit;
}

if (in_array($_SERVER['REQUEST_METHOD'], $allowedMethods)) {
    $resource = ltrim($uri, '/'); // Ex: /products/123 => products/123

    // Récupération de la ressource principale (ex: 'products')
    $parts = explode('/', $resource);
    $resourceName = $parts[0] ?? '';

    if (!in_array($resourceName, $allowedResources)) {
        http_response_code(403);
        echo json_encode(['error' => 'Ressource non autorisée']);
        logMessage('Forbidden resource access attempt: ' . $resourceName);
        exit;
    }

    // Construit l'URL finale (ex: /products/123)
    $apiUrl = $baseApiUrl . $resource;
    $ch = curl_init($apiUrl);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $_SERVER['REQUEST_METHOD']);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Authorization: Basic ' . base64_encode($apiKey . ':'),
        'Accept: application/json, application/xml',
    ]);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

    // Si POST, PUT, PATCH → envoyer le body reçu
    if (in_array($_SERVER['REQUEST_METHOD'], ['POST', 'PUT', 'PATCH'])) {
        $body = file_get_contents('php://input');
        curl_setopt($ch, CURLOPT_POSTFIELDS, $body);
    }

    $response = curl_exec($ch);
    $status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $curlError = curl_error($ch);
    curl_close($ch);

    if ($response === false || $status >= 400) {
        http_response_code($status ?: 500);
        echo json_encode(['error' => 'Erreur API', 'details' => $response ?: $curlError]);
        logMessage('Proxy error on ' . $_SERVER['REQUEST_METHOD'] . ' ' . $resource . ' : ' . ($curlError ?: $response));
        exit;
    }

    header('Content-Type: application/json');
    echo $response;
    logMessage('Proxy success: ' . $_SERVER['REQUEST_METHOD'] . ' ' . $resource);
    exit;
}

// Si aucune correspondance
http_response_code(404);
echo json_encode(['error' => 'Route non trouvée']);
logMessage('Route not found: ' . $uri);
exit;

?>.      Depuis le frontend de mon application j'ai deja reussire à m'inscrir et à me connecter . un fois connnecter la page d'acceuil viens mais je ne vois aucun produit . comment gerer le chargement des produis depuis prestashop
curl -X GET "http://localhost:8080/prestashop/proxy.php/products?output_format=JSON&display=full" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json"
