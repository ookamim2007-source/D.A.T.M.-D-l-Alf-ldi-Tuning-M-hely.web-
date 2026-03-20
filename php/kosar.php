<?php
session_start();

if (isset($_GET['action']) && $_GET['action'] == 'remove' && isset($_GET['id'])) {
    $remove_id = $_GET['id'];
    if (isset($_SESSION['cart'][$remove_id])) {
        unset($_SESSION['cart'][$remove_id]);
    }
    
    header("Location: kosar.php");
    exit;
}

if (isset($_POST['add_to_cart'])) {
    $id = $_POST['item_id'];
    $_SESSION['cart'][$id] = [
        'motor_kod' => $_POST['motor_kod'],
        'loero' => $_POST['loero'],
        'turbo' => $_POST['turbo'],
        'ar' => 155000 
    ];
}


if (isset($_POST['place_order'])) {
    if (!empty($_SESSION['cart'])) {
  
        $_SESSION['last_order'] = [
            'items' => $_SESSION['cart'],
            'total' => array_sum(array_column($_SESSION['cart'], 'ar')),
            'date' => date('Y-m-d H:i:s')
        ];
        
 
        $_SESSION['cart'] = [];
        

        header("Location: kosar.php?order_success=1");
        exit;
    }
}

$order_success = isset($_GET['order_success']) && $_GET['order_success'] == 1;
$last_order = isset($_SESSION['last_order']) ? $_SESSION['last_order'] : null;

if ($order_success && $last_order) {
 
}
?>

<!DOCTYPE html>
<html lang="hu">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://fonts.googleapis.com">
    <link href="https://cdn.jsdelivr.net" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Audiowide">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <title>D.A.T.M. Tuning műhely - Kosár</title>
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            overflow-x: hidden;
            background-color: #f5f5f5;
            font-family: "Audiowide", sans-serif;
        }

        ::-webkit-scrollbar {
            width: 10px;
        }

        ::-webkit-scrollbar-track {
            background: #2c3e50;
        }

        ::-webkit-scrollbar-thumb {
            background: #f11e3a;
            border-radius: 5px;
        }

        ::-webkit-scrollbar-thumb:hover {
            background: #be1229;
        }
        .focim {
            margin-left: 3%;
            font-size: 35px;
            font-style: italic;
            letter-spacing: 3.4vh;
            font-weight: bolder;
            width:100;
        }
        
        .focim a {
            text-decoration: none;
            color: white;
        }
        
        .ikonok {
            font-size: 34px;
            margin-right: -18vh;
        }

        .ikonok a {
            text-decoration: none;
            color: white;
        }

        .ikkon {
            height: 30px;
            width: 30px;
            margin-left: 15px;
            margin-right: 15px;
        }

        .ikkon:hover {
            transition: 0.2s;
            color: rgb(170, 41, 13);
        }

        .navbar {
            background-image: radial-gradient(circle ,rgb(38, 54, 70) -10%, #2c3e50 100%);
            position: fixed;
            top: 0;
            width: 100%;
            z-index: 1000;
            height:8.7%;
        }

        .main {
            padding: 120px 30px 50px 30px;
            min-height: 100vh;
            background-image: url("../Kepek/jokjep.png"); 
            background-attachment: fixed;
            background-position: right;
            background-color: #af1106;
            background-repeat: no-repeat;
        }
     
        .kosarcim {
            text-align: center;
            font-weight: 999;
            font-size: 80px;
            text-shadow: 0 0 10px rgba(255, 255, 255, 0.8), 
                         0 0 20px rgba(255, 255, 255, 0.5);
        }
        

        .kosar-box {
            background: rgba(0, 0, 0, 0.8);
            border-radius: 20px;
            padding: 40px;
            color: white;
            box-shadow: 0 20px 50px rgba(0,0,0,0.5);
            border: 1px solid rgba(179, 33, 52, 0.3);
        }

        .table {
            --bs-table-bg: transparent;
            --bs-table-color: white;
            margin-top: 20px;
        }

        .item-sor:hover {
            background: rgba(179, 33, 52, 0.15) !important;
        }

        .btn-tuning {
            background-color: #B32134;
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 50px;
            font-weight: bold;
            letter-spacing: 1px;
            transition: 0.3s;
        }

        .btn-tuning:hover {
            background-color: #ff2e44;
            transform: scale(1.05);
            color: white;
        }

        .ures-szoveg {
            text-align: center;
            font-size: 24px;
            padding: 60px;
            color: rgba(255,255,255,0.6);
        }
        

        .modal-content {
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            color: white;
            border: 2px solid #B32134;
            border-radius: 20px;
        }
        
        .modal-header {
            border-bottom: 2px solid #B32134;
            background: rgba(179, 33, 52, 0.2);
        }
        
        .modal-footer {
            border-top: 2px solid #B32134;
        }
        
        .order-item {
            background: rgba(255, 255, 255, 0.05);
            border-radius: 10px;
            padding: 10px;
            margin-bottom: 10px;
            transition: 0.3s;
        }
        
        .order-item:hover {
            background: rgba(179, 33, 52, 0.2);
            transform: translateX(5px);
        }
        
        .order-total {
            font-size: 24px;
            font-weight: bold;
            color: #B32134;
            text-align: right;
            padding-top: 15px;
            border-top: 2px solid #B32134;
        }
        
        .order-date {
            color: #B32134;
            font-size: 12px;
            text-align: right;
            margin-bottom: 15px;
        }
        
        .btn-close-white {
            filter: invert(1) grayscale(100%) brightness(200%);
        }
        
        .check-icon {
            font-size: 60px;
            color: #27ae60;
            animation: bounce 0.5s ease;
        }
        
        @keyframes bounce {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.2); }
        }
        
        .order-list {
            max-height: 400px;
            overflow-y: auto;
            padding-right: 10px;
        }
        
        .order-list::-webkit-scrollbar {
            width: 5px;
        }
        
        .order-list::-webkit-scrollbar-track {
            background: rgba(255,255,255,0.1);
            border-radius: 10px;
        }
        
        .order-list::-webkit-scrollbar-thumb {
            background: #B32134;
            border-radius: 10px;
        }
        
        .item-badge {
            background: #B32134;
            border-radius: 20px;
            padding: 2px 8px;
            font-size: 11px;
            font-weight: normal;
        }
        
        .motor-code {
            font-weight: bold;
            color: #B32134;
        }
    </style>
</head>
<body>

<div class="container-fluid">
    <div class="row navbar align-items-center py-2">
        <div class="col-9 focim">
            <a href="?">D.A.T.M. Tuning műhely</a>
        </div>
        <div class="col-3 ikonok d-flex">
            <a href="">
                <i class="bi bi-moon-stars ikkon"></i>
            </a>
            <a href="kosar.php">
                <i class="bi bi-cart3 ikkon"></i>
            </a>
            <a href="#">
                <i class="bi bi-person-circle ikkon"></i>
            </a>
            <a href="#">
                <i class="bi bi-gear ikkon"></i>
            </a>
        </div>
    </div>
</div>

<div class="main">
    <h1 class="kosarcim">KOSÁR</h1>
    
    <div class="container kosar-box">
        <?php if (!empty($_SESSION['cart'])): ?>
            <div class="table-responsive">
                <table class="table align-middle">
                    <thead>
                        <tr style="border-bottom: 2px solid #B32134; color: #B32134;">
                            <th>Alkatrész / Motor</th>
                            <th>Specifikáció</th>
                            <th>Ár</th>
                            <th class="text-center">Művelet</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php 
                        $osszesen = 0;
                        foreach ($_SESSION['cart'] as $id => $item): 
                            $osszesen += $item['ar'];
                        ?>
                        <tr class="item-sor" style="border-bottom: 1px solid rgba(255,255,255,0.1);">
                            <td class="py-4">
                                <div class="fs-5 fw-bold text-white"><?php echo htmlspecialchars($item['motor_kod']); ?></div>
                                <small class="text-danger">Tuning alkatrész</small>
                            </td>
                            <td>
                                <i class="bi bi-speedometer2 me-2"></i><?php echo $item['loero']; ?> LE<br>
                                <i class="bi bi-turbine me-2"></i><?php echo htmlspecialchars($item['turbo']); ?>
                            </td>
                            <td class="fs-5 fw-bold"><?php echo number_format($item['ar'], 0, ',', ' '); ?> Ft</td>
                            <td class="text-center">
                                <a href="?action=remove&id=<?php echo $id; ?>" class="text-danger fs-4">
                                    <i class="bi bi-trash3-fill"></i>
                                </a>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                    <tfoot>
                        <tr class="fs-3 fw-bold">
                            <td colspan="2" class="text-end py-4">Végösszeg:</td>
                            <td colspan="2" style="color: #B32134;"><?php echo number_format($osszesen, 0, ',', ' '); ?> Ft</td>
                        </tr>
                    </tfoot>
                </table>
            </div>

            <div class="d-flex justify-content-between mt-5">
                <a href="alkreszek.php" class="btn btn-outline-light rounded-pill px-4 align-self-center">Válogatás folytatása</a>
                <button class="btn btn-tuning shadow-lg" data-bs-toggle="modal" data-bs-target="#orderModal">MEGRENDELÉS LEADÁSA <i class="bi bi-chevron-right ms-2"></i></button>
            </div>

        <?php else: ?>
            <div class="ures-szoveg">
                <i class="bi bi-cart-x mb-4 d-block" style="font-size: 100px; color: #B32134;"></i>
                Még nem választottál semmit a szörnyetegedhez.
                <div class="mt-5">
                    <a href="alkreszek.php" class="btn btn-tuning">IRÁNY A WEBSHOP</a>
                </div>
            </div>
        <?php endif; ?>
    </div>
</div>

<div class="modal fade" id="orderModal" tabindex="-1" aria-labelledby="orderModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="orderModalLabel">
                    <i class="bi bi-check-circle-fill me-2" style="color: #27ae60;"></i>
                    Rendelés összegzése
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="text-center mb-4">
                    <i class="bi bi-cart-check-fill check-icon"></i>
                    <h3 class="mt-3">Rendelés összegzése</h3>
                    <p class="text-muted">Kérjük erősítse meg rendelését</p>
                </div>
                
                <div class="order-list">
                    <?php 
                    $modal_osszesen = 0;
                    foreach ($_SESSION['cart'] as $item): 
                        $modal_osszesen += $item['ar'];
                    ?>
                    <div class="order-item d-flex justify-content-between align-items-center">
                        <div class="flex-grow-1">
                            <div class="fw-bold">
                                <i class="bi bi-cpu me-2 text-danger"></i>
                                <span class="motor-code"><?php echo htmlspecialchars($item['motor_kod']); ?></span>
                                <span class="item-badge ms-2">Tuning</span>
                            </div>
                            <div class="small text-muted mt-1">
                                <i class="bi bi-speedometer2 me-1"></i><?php echo $item['loero']; ?> LE | 
                                <i class="bi bi-turbine me-1"></i><?php echo htmlspecialchars($item['turbo']); ?>
                            </div>
                        </div>
                        <div class="fw-bold text-danger ms-3">
                            <?php echo number_format($item['ar'], 0, ',', ' '); ?> Ft
                        </div>
                    </div>
                    <?php endforeach; ?>
                </div>
                
                <div class="order-total mt-3">
                    Összesen: <?php echo number_format($modal_osszesen, 0, ',', ' '); ?> Ft
                </div>
                <div class="order-date mt-2">
                    <i class="bi bi-clock me-1"></i>Rendelés időpontja: <?php echo date('Y-m-d H:i:s'); ?>
                </div>
                
                <div class="alert alert-info mt-3" role="alert" style="background: rgba(179, 33, 52, 0.2); border-color: #B32134; color: white;">
                    <i class="bi bi-info-circle-fill me-2"></i>
                    A rendelés leadása után a kosár tartalma automatikusan kiürül.
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-light rounded-pill px-4" data-bs-dismiss="modal">Mégsem</button>
                <form method="POST" style="display: inline;">
                    <button type="submit" name="place_order" class="btn btn-tuning rounded-pill px-4">
                        <i class="bi bi-check-lg me-2"></i>Rendelés véglegesítése
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>

<?php if ($order_success && $last_order): ?>
<div class="modal fade" id="successModal" tabindex="-1" aria-labelledby="successModalLabel" aria-hidden="true" data-bs-backdrop="static">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="successModalLabel">
                    <i class="bi bi-check-circle-fill me-2" style="color: #27ae60;"></i>
                    Rendelés sikeresen leadva!
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="text-center">
                    <i class="bi bi-trophy-fill" style="font-size: 80px; color: #f39c12;"></i>
                    <h4 class="mt-3">Köszönjük a rendelést!</h4>
                    <p class="mt-3">A rendelés részletei:</p>
                </div>
                
                <div class="order-list mb-3" style="max-height: 300px;">
                    <?php foreach ($last_order['items'] as $item): ?>
                    <div class="order-item d-flex justify-content-between align-items-center">
                        <div>
                            <div class="fw-bold"><?php echo htmlspecialchars($item['motor_kod']); ?></div>
                            <div class="small text-muted"><?php echo htmlspecialchars($item['turbo']); ?> | <?php echo $item['loero']; ?> LE</div>
                        </div>
                        <div class="fw-bold text-danger"><?php echo number_format($item['ar'], 0, ',', ' '); ?> Ft</div>
                    </div>
                    <?php endforeach; ?>
                </div>
                
                <div class="order-total text-center">
                    Végösszeg: <?php echo number_format($last_order['total'], 0, ',', ' '); ?> Ft
                </div>
                <div class="text-center text-muted small mt-2">
                    <i class="bi bi-calendar-check me-1"></i><?php echo $last_order['date']; ?>
                </div>
                
                <div class="alert alert-success mt-3 text-center" role="alert">
                    <i class="bi bi-envelope-paper-fill me-2"></i>
                    A rendelés visszaigazolását e-mailben elküldtük!
                </div>
            </div>
            <div class="modal-footer">
                <a href="alkreszek.php" class="btn btn-tuning rounded-pill px-4">
                    <i class="bi bi-shop me-2"></i>További vásárlás
                </a>
                <button type="button" class="btn btn-outline-light rounded-pill px-4" data-bs-dismiss="modal">Bezárás</button>
            </div>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        var successModal = new bootstrap.Modal(document.getElementById('successModal'));
        successModal.show();
        
       
        document.getElementById('successModal').addEventListener('hidden.bs.modal', function () {
            window.location.href = 'kosar.php';
        });
    });
</script>
<?php 
    unset($_SESSION['last_order']);
endif; 
?>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
