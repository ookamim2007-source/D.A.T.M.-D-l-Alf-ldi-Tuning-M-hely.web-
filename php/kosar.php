<?php
session_start();

// --- 1. LOGIKA: Törlés a kosárból ---
if (isset($_GET['action']) && $_GET['action'] == 'remove' && isset($_GET['id'])) {
    $remove_id = $_GET['id'];
    if (isset($_SESSION['cart'][$remove_id])) {
        unset($_SESSION['cart'][$remove_id]);
    }
    // Frissítés, hogy ne maradjon ott az URL-ben a törlési parancs
    header("Location: kosar.php");
    exit;
}

// --- 2. LOGIKA: Tétel hozzáadása (ha a másik oldalról POST-tal jön adat) ---
if (isset($_POST['add_to_cart'])) {
    $id = $_POST['item_id'];
    $_SESSION['cart'][$id] = [
        'motor_kod' => $_POST['motor_kod'],
        'loero' => $_POST['loero'],
        'turbo' => $_POST['turbo'],
        'ar' => 155000 // Itt fix árat adtam meg, de jöhet adatbázisból is
    ];
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
            background-image: url("../Kepek/jokjep.png"); /* Ellenőrizd az elérési utat! */
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
                                        <i class="bi bi-trash3-fill ikkon"></i>
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
                    <a href="alkatreszek.php" class="btn btn-outline-light rounded-pill px-4 align-self-center">Válogatás folytatása</a>
                    <button class="btn btn-tuning shadow-lg">MEGRENDELÉS LEADÁSA <i class="bi bi-chevron-right ms-2"></i></button>
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

</body>
</html>