<?php
// MarketNest - PrestaShop API Proxy
// Enhanced version with better error handling and API compatibility

// Disable deprecated errors for PHP 8.2+
error_reporting(E_ALL & ~E_DEPRECATED & ~E_NOTICE);
ini_set('display_errors', 0);

// CORS Headers
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Cache-Control: no-cache, must-revalidate');
header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
header('Content-Type: application/json; charset=utf-8');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Configuration
$apiKey = getenv('PRESTASHOP_API_KEY') ?: 'WD4YUTKV1136122LWTI64EQCMXAIM99S';
$baseApiUrl = 'http://localhost:8080/prestashop/api/';
$logFile = __DIR__ . '/api_proxy.log';

// Allowed resources from PrestaShop
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
];

$allowedMethods = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'HEAD'];

// Utility functions
function logMessage($message) {
    global $logFile;
    $timestamp = date('Y-m-d H:i:s');
    file_put_contents($logFile, "[$timestamp] $message\n", FILE_APPEND);
}

function respondWithError($code, $message, $details = null) {
    http_response_code($code);
    $response = ['error' => $message];
    if ($details) {
        $response['details'] = $details;
    }
    echo json_encode($response);
    logMessage("Error $code: $message");
    exit();
}

function respondWithSuccess($data, $message = null) {
    http_response_code(200);
    $response = ['success' => true];
    if ($message) {
        $response['message'] = $message;
    }
    if ($data) {
        $response = array_merge($response, $data);
    }
    echo json_encode($response);
    exit();
}

function callPrestaShopApi($method, $endpoint, $data = null) {
    global $apiKey, $baseApiUrl;
    
    $url = $baseApiUrl . ltrim($endpoint, '/');
    
    // Add output_format=JSON for GET requests
    if ($method === 'GET' && strpos($url, 'output_format=') === false) {
        $url .= (strpos($url, '?') === false ? '?' : '&') . 'output_format=JSON';
    }
    
    $ch = curl_init();
    curl_setopt_array($ch, [
        CURLOPT_URL => $url,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_CUSTOMREQUEST => $method,
        CURLOPT_HTTPHEADER => [
            'Authorization: Basic ' . base64_encode($apiKey . ':'),
            'Content-Type: application/xml',
            'Accept: application/xml'
        ],
        CURLOPT_FOLLOWLOCATION => true,
        CURLOPT_TIMEOUT => 30,
        CURLOPT_SSL_VERIFYPEER => false,
    ]);
    
    if ($data !== null) {
        curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
    }
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $curlError = curl_error($ch);
    curl_close($ch);
    
    if ($response === false) {
        throw new Exception("cURL Error: $curlError");
    }
    
    if ($httpCode >= 400) {
        throw new Exception("API Error: HTTP $httpCode - $response");
    }
    
    return ['response' => $response, 'httpCode' => $httpCode];
}

// Parse request URI
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$uri = str_replace('/prestashop/proxy.php', '', $uri);
$method = $_SERVER['REQUEST_METHOD'];

// -------------------- AUTHENTICATION ENDPOINTS --------------------

// LOGIN endpoint
if ($uri === '/login' && $method === 'POST') {
    $json = json_decode(file_get_contents('php://input'), true);
    if (!$json || !isset($json['email'], $json['passwd'])) {
        respondWithError(400, 'Email and password are required');
    }
    
    $email = $json['email'];
    $passwd = $json['passwd'];
    
    try {
        // Find customer by email
        $result = callPrestaShopApi('GET', "customers?output_format=JSON&filter[email]=" . urlencode($email));
        $customerData = json_decode($result['response'], true);
        
        if (!$customerData || !isset($customerData['customers'][0])) {
            respondWithError(401, 'User not found');
        }
        
        $customerId = $customerData['customers'][0]['id'];
        
        // Get full customer details
        $result = callPrestaShopApi('GET', "customers/$customerId");
        $xmlObj = simplexml_load_string($result['response']);
        
        if (!$xmlObj) {
            respondWithError(500, 'Failed to parse customer data');
        }
        
        $customer = $xmlObj->customer;
        $storedHash = trim((string) $customer->passwd);
        
        if (!password_verify($passwd, $storedHash)) {
            respondWithError(401, 'Invalid password');
        }
        
        respondWithSuccess([
            'customer' => $customerData['customers'][0],
            'token' => base64_encode(json_encode(['id' => $customerId, 'email' => $email]))
        ], 'Login successful');
        
    } catch (Exception $e) {
        respondWithError(500, $e->getMessage());
    }
}

// SIGNUP endpoint
if ($uri === '/signup' && $method === 'POST') {
    $json = json_decode(file_get_contents('php://input'), true);
    if (!$json || !isset($json['customer'])) {
        respondWithError(400, 'Customer data is required');
    }
    
    $customer = $json['customer'];
    $requiredFields = ['firstname', 'lastname', 'email', 'passwd'];
    
    foreach ($requiredFields as $field) {
        if (empty($customer[$field])) {
            respondWithError(400, "Required field missing: $field");
        }
    }
    
    try {
        // Get blank customer schema
        $result = callPrestaShopApi('GET', 'customers?schema=blank');
        $xml = simplexml_load_string($result['response']);
        
        if (!$xml) {
            respondWithError(500, 'Failed to get customer schema');
        }
        
        // Fill schema with customer data
        foreach ($customer as $key => $value) {
            if (isset($xml->customer->$key)) {
                $xml->customer->$key = $value;
            }
        }
        
        // Set default values
        $xml->customer->active = $customer['active'] ?? 1;
        $xml->customer->id_default_group = $customer['id_default_group'] ?? 3;
        
        // Create customer
        $result = callPrestaShopApi('POST', 'customers', $xml->asXML());
        
        respondWithSuccess(null, 'Account created successfully');
        
    } catch (Exception $e) {
        respondWithError(500, $e->getMessage());
    }
}

// -------------------- GENERIC API PROXY --------------------

// Parse resource from URI
$pathParts = explode('/', trim($uri, '/'));
$resource = $pathParts[0] ?? '';
$resourceId = $pathParts[1] ?? '';

// Validate resource
if (!in_array($resource, $allowedResources)) {
    respondWithError(404, 'Resource not found');
}

// Validate method
if (!in_array($method, $allowedMethods)) {
    respondWithError(405, 'Method not allowed');
}

// Build API endpoint
$endpoint = $resource;
if ($resourceId) {
    $endpoint .= '/' . $resourceId;
}

// Add query parameters
if (!empty($_GET)) {
    $endpoint .= '?' . http_build_query($_GET);
}

// Get request data for POST/PUT/PATCH
$requestData = null;
if (in_array($method, ['POST', 'PUT', 'PATCH'])) {
    $requestData = file_get_contents('php://input');
    
    // Convert JSON to XML if needed
    if ($requestData && strpos($requestData, '{') === 0) {
        $json = json_decode($requestData, true);
        if ($json) {
            // Simple JSON to XML conversion for basic operations
            $xml = new SimpleXMLElement('<prestashop/>');
            foreach ($json as $key => $value) {
                if (is_array($value)) {
                    $child = $xml->addChild($key);
                    foreach ($value as $subKey => $subValue) {
                        $child->addChild($subKey, htmlspecialchars($subValue));
                    }
                } else {
                    $xml->addChild($key, htmlspecialchars($value));
                }
            }
            $requestData = $xml->asXML();
        }
    }
}

try {
    $result = callPrestaShopApi($method, $endpoint, $requestData);
    
    // For DELETE and HEAD methods, return simple success
    if (in_array($method, ['DELETE', 'HEAD'])) {
        respondWithSuccess(null, "Operation $method successful on $resource");
    }
    
    // Parse XML response and convert to JSON
    libxml_use_internal_errors(true);
    $xml = simplexml_load_string($result['response']);
    
    if ($xml === false) {
        $errors = libxml_get_errors();
        respondWithError(500, 'Failed to parse response', array_map(fn($e) => $e->message, $errors));
    }
    
    // Convert XML to JSON
    $jsonData = json_encode($xml);
    $data = json_decode($jsonData, true);
    
    http_response_code(200);
    echo json_encode($data);
    
} catch (Exception $e) {
    respondWithError(500, $e->getMessage());
}
?>
