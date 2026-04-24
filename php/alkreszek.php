
<?php
session_start();

$user = 'root';
$password = '';
$database = 'turbo_webshop';
$servername = 'localhost';

$mysqli = new mysqli($servername, $user, $password, $database);

if ($mysqli->connect_error) {
    die('Connect Error (' . $mysqli->connect_errno . ') ' . $mysqli->connect_error);
}

$gyartok_sql = "SELECT id, name as nev FROM manufacturers ORDER BY name";
$gyartok_result = $mysqli->query($gyartok_sql);

// JAVÍTVA: fitment_note használata alkalmassag helyett
$kategoriak_sql = "SELECT DISTINCT fitment_note as kat_nev, fitment_note as leiras FROM engine_turbo_fitment etf 
                   JOIN turbos t ON etf.turbo_id = t.id 
                   WHERE etf.fitment_note IS NOT NULL AND etf.fitment_note != ''
                   UNION SELECT 'Gyári', 'Gyári' 
                   UNION SELECT 'Performance', 'Performance' 
                   UNION SELECT 'Verseny', 'Verseny' 
                   UNION SELECT 'Drag', 'Drag' 
                   UNION SELECT 'Daily', 'Daily' 
                   ORDER BY kat_nev";
$kategoriak_result = $mysqli->query($kategoriak_sql);

// Ha a fenti lekérdezés hibát ad, használd ezt az egyszerűbb változatot:
if (!$kategoriak_result) {
    // Egyszerűbb megoldás: fix kategória lista
    $kategoriak_result = null;
}

$selected_gyarto = isset($_GET['gyarto']) ? (int)$_GET['gyarto'] : 0;
$selected_kategoria = isset($_GET['kategoria']) ? (int)$_GET['kategoria'] : 0;

$kategoria_nev = '';
if ($selected_kategoria > 0) {
    $kategoria_map = [
        1 => 'Gyári',
        2 => 'Performance', 
        3 => 'Verseny',
        4 => 'Drag',
        5 => 'Daily'
    ];
    $kategoria_nev = isset($kategoria_map[$selected_kategoria]) ? $kategoria_map[$selected_kategoria] : '';
}

$alkatreszek = [];
if ($selected_gyarto > 0 && $selected_kategoria > 0 && !empty($kategoria_nev)) {
    // JAVÍTVA: fitment_note használata
    $alkatresz_sql = "SELECT 
                        es.engine_code as motor_kod,
                        'N/A' as loero,
                        'N/A' as hengerurtartalom,
                        t.model AS turbo_modell,
                        tm.name AS turbo_gyarto,
                        etf.fitment_note as alkalmassag,
                        '200' as teljesitmeny_tartomany_from,
                        '600' as teljesitmeny_tartomany_to
                      FROM engine_turbo_fitment etf
                      JOIN engine_series es ON etf.engine_id = es.id
                      JOIN manufacturers m ON es.manufacturer_id = m.id
                      JOIN turbos t ON etf.turbo_id = t.id
                      JOIN turbo_manufacturers tm ON t.manufacturer_id = tm.id
                      WHERE m.id = ? 
                      AND (etf.fitment_note = ? OR (etf.fitment_note IS NULL AND ? = 'Gyári'))
                      ORDER BY es.engine_code
                      LIMIT 9"; 
    
    $stmt = $mysqli->prepare($alkatresz_sql);
    if ($stmt) {
        $stmt->bind_param("iss", $selected_gyarto, $kategoria_nev, $kategoria_nev);
        $stmt->execute();
        $alkatreszek_result = $stmt->get_result();
        $alkatreszek = $alkatreszek_result->fetch_all(MYSQLI_ASSOC);
        $stmt->close();
    }
}

$gyarto_nev = '';
if ($selected_gyarto > 0) {
    $gyarto_sql = "SELECT name as nev FROM manufacturers WHERE id = ?";
    $stmt = $mysqli->prepare($gyarto_sql);
    $stmt->bind_param("i", $selected_gyarto);
    $stmt->execute();
    $gyarto_result = $stmt->get_result();
    if ($gyarto_row = $gyarto_result->fetch_assoc()) {
        $gyarto_nev = $gyarto_row['nev'];
    }
    $stmt->close();
}

$kategoria_nevek = [
    1 => 'Gyári',
    2 => 'Performance',
    3 => 'Verseny',
    4 => 'Drag',
    5 => 'Daily'
];
?>

<!DOCTYPE html>
<html lang="hu">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <title>D.A.T.M. Tuning műhely - Alkatrészek</title>
    <style>
        /* Összes stílus ugyanaz marad, mint az előző verzióban */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #0a0a0a;
            overflow-x: hidden;
        }

        body::before {
            content: "";
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: url("../Kepek/jokjep.png");
            background-size: cover;
            background-position: right;
            background-repeat: no-repeat;
            filter: blur(2px);
            z-index: -2;
        }

        body::after {
            content: "";
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.3);
            z-index: -1;
        }

        ::-webkit-scrollbar {
            width: 8px;
        }

        ::-webkit-scrollbar-track {
            background: #1a1a1a;
        }

        ::-webkit-scrollbar-thumb {
            background: #e74c3c;
            border-radius: 4px;
        }

        ::-webkit-scrollbar-thumb:hover {
            background: #c0392b;
        }

        .navbar {
            position: fixed;
            height:8%;
            top: 0;
            width: 100%;
            z-index: 1000;
            background: rgba(0, 0, 0, 0.85);
            backdrop-filter: blur(10px);
            padding: 12px 0;
            border-bottom: 1px solid rgba(231, 76, 60, 0.3);
        }

        .focim {
            font-size: 28px;
            font-weight: bold;
            letter-spacing: 2px;
            padding-left: 5%;
        }

        .focim a {
            color: #e74c3c;
            text-decoration: none;
            transition: color 0.3s;
        }

        .focim a:hover {
            color: #c0392b;
        }

        .ikonok {
            display: flex;
            justify-content: flex-end;
            gap: 25px;
            padding-right: 3%;
        }

        .ikonok a {
            color: #ecf0f1;
            font-size: 24px;
            transition: color 0.3s;
            text-decoration: none;
        }

        .ikonok a:hover {
            color: #e74c3c;
        }

        .oldal {
            position: fixed;
            left: 0;
            top: 70px;
            width: 280px;
            height: calc(100vh - 70px);
            background: rgba(0, 0, 0, 0.85);
            backdrop-filter: blur(10px);
            padding: 20px 0;
            overflow-y: auto;
            z-index: 900;
            border-right: 1px solid rgba(231, 76, 60, 0.3);
        }

        .oldal h3 {
            color: #e74c3c;
            font-size: 18px;
            text-transform: uppercase;
            letter-spacing: 2px;
            padding: 0 20px;
            margin-bottom: 15px;
        }

        .search-container {
            padding: 0 20px 20px;
            display: flex;
            align-items: center;
        }

        .kereso {
            flex: 1;
            padding: 10px 15px;
            border: 1px solid rgba(231, 76, 60, 0.3);
            border-radius: 25px;
            background: rgba(255, 255, 255, 0.1);
            color: #ecf0f1;
            outline: none;
        }

        .kereso:focus {
            border-color: #e74c3c;
        }

        .kereso::placeholder {
            color: #95a5a6;
        }

        .keresoikon {
            margin-left: 12px;
            color: #e74c3c;
            font-size: 18px;
        }

        .gyarto-fejlec {
            padding: 12px 20px;
            color: #ecf0f1;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-left: 3px solid transparent;
        }

        .gyarto-fejlec:hover {
            background: rgba(231, 76, 60, 0.2);
            border-left-color: #e74c3c;
        }

        .gyarto-fejlec.active {
            background: rgba(231, 76, 60, 0.3);
            border-left-color: #e74c3c;
        }

        .kategoria-lista {
            display: none;
            background: rgba(0, 0, 0, 0.5);
            padding: 5px 0;
        }

        .kategoria-lista.show {
            display: block;
        }

        .kategoria-lista a {
            padding: 10px 20px 10px 40px;
            color: #bdc3c7;
            text-decoration: none;
            display: block;
            font-size: 14px;
            transition: all 0.3s;
        }

        .kategoria-lista a:hover {
            background: rgba(231, 76, 60, 0.2);
            color: #e74c3c;
        }

        .kategoria-lista a.active {
            background: rgba(231, 76, 60, 0.3);
            color: #e74c3c;
        }

        .main {
            margin-left: 260px;
            padding: 90px 30px 40px;
            min-height: 100vh;
        }

        #cim {
            text-align: center;
            margin-bottom: 40px;
        }

        .markacim {
            font-size: 60px;
            font-weight: bold;
            color: #e74c3c;
            text-shadow: 0 0 20px rgba(231, 76, 60, 0.5);
            letter-spacing: 4px;
        }

        .kategoria-cim {
            text-align: center;
            margin-bottom: 30px;
            color: #ecf0f1;
            font-size: 20px;
        }

        .kategoria-cim span {
            color: #e74c3c;
            font-weight: bold;
        }

        .kartya {
            background: rgba(0, 0, 0, 0.7);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(231, 76, 60, 0.3);
            border-radius: 15px;
            color: #ecf0f1;
            padding: 20px;
            margin-bottom: 25px;
            transition: all 0.3s;
            cursor: pointer;
        }

        .kartya:hover {
            transform: translateY(-5px);
            border-color: #e74c3c;
            box-shadow: 0 10px 30px rgba(231, 76, 60, 0.2);
        }

        .kartya-ikon {
            font-size: 48px;
            color: #e74c3c;
            margin-bottom: 15px;
            display: block;
            text-align: center;
        }

        .kartya h4 {
            text-align: center;
            margin-bottom: 15px;
            color: #e74c3c;
        }

        .kartya-adat p {
            margin: 8px 0;
            font-size: 14px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            padding-bottom: 5px;
        }

        .kartya-adat i {
            color: #e74c3c;
            margin-right: 8px;
        }

        .kartya-ures {
            background: rgba(0, 0, 0, 0.5);
            text-align: center;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 280px;
        }

        .kartya-ures .kartya-ikon {
            font-size: 48px;
            color: #7f8c8d;
        }

        .badge-alkalmassag {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: bold;
        }

        .badge-Gyári { background: #27ae60; color: white; }
        .badge-Performance { background: #2980b9; color: white; }
        .badge-Verseny { background: #e74c3c; color: white; }
        .badge-Drag { background: #8e44ad; color: white; }
        .badge-Daily { background: #f39c12; color: white; }

        .btn-add-to-cart {
            background: #e74c3c;
            color: white;
            border: none;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 14px;
            transition: all 0.3s;
        }

        .btn-add-to-cart:hover {
            background: #c0392b;
            transform: scale(1.05);
        }

        .profile-modal .modal-content,
        .opinion-modal .modal-content,
        .success-modal .modal-content {
            background: rgba(0, 0, 0, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid #e74c3c;
            border-radius: 20px;
            color: #ecf0f1;
        }

        .profile-modal .modal-header,
        .opinion-modal .modal-header,
        .success-modal .modal-header {
            border-bottom: 1px solid #e74c3c;
        }

        .profile-modal .modal-footer,
        .opinion-modal .modal-footer,
        .success-modal .modal-footer {
            border-top: 1px solid #e74c3c;
        }

        .profile-avatar {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #e74c3c, #c0392b);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 15px;
        }

        .profile-avatar i {
            font-size: 50px;
            color: white;
        }

        .profile-name {
            text-align: center;
            font-size: 22px;
            font-weight: bold;
            margin-bottom: 5px;
        }

        .profile-email {
            text-align: center;
            color: #e74c3c;
            margin-bottom: 20px;
        }

        .profile-menu-item {
            padding: 12px 20px;
            margin: 5px 0;
            border-radius: 10px;
            transition: all 0.3s;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .profile-menu-item:hover {
            background: rgba(231, 76, 60, 0.2);
        }

        .profile-menu-item i:first-child {
            width: 25px;
            color: #e74c3c;
        }

        .logout-btn {
            color: #e74c3c;
        }

        .logout-btn:hover {
            background: rgba(231, 76, 60, 0.3);
        }

        .star-rating {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin: 20px 0;
        }

        .star-rating i {
            font-size: 35px;
            cursor: pointer;
            color: #555;
            transition: all 0.2s;
        }

        .star-rating i:hover,
        .star-rating i.active {
            color: #f1c40f;
        }

        .opinion-textarea {
            width: 100%;
            padding: 12px;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid #e74c3c;
            border-radius: 10px;
            color: white;
            resize: vertical;
        }

        .opinion-textarea:focus {
            outline: none;
            border-color: #c0392b;
        }

        .success-icon {
            font-size: 70px;
            color: #27ae60;
            margin: 20px 0;
            animation: bounce 0.5s ease;
        }

        @keyframes bounce {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.2); }
        }

        .btn-close-white {
            filter: invert(1);
        }

        .ures-szoveg {
            text-align: center;
            padding: 60px 20px;
            color: #ecf0f1;
        }

        .ures-szoveg i {
            font-size: 80px;
            color: #e74c3c;
            margin-bottom: 20px;
        }

        .btn-tuning {
            background: #e74c3c;
            color: white;
            border: none;
            padding: 10px 25px;
            border-radius: 30px;
            transition: all 0.3s;
        }

        .btn-tuning:hover {
            background: #c0392b;
            transform: translateY(-2px);
        }

        .btn-outline-light {
            border: 1px solid #e74c3c;
            color: #e74c3c;
        }

        .btn-outline-light:hover {
            background: #e74c3c;
            color: white;
        }

        @media (max-width: 768px) {
            .oldal {
                width: 100%;
                height: auto;
                position: relative;
                top: 70px;
                left: 0;
                transform: translateX(-100%);
                transition: transform 0.3s;
                z-index: 1001;
            }
            
            .oldal.open {
                transform: translateX(0);
            }
            
            .main {
                margin-left: 0;
                padding: 80px 15px 30px;
            }
            
            .markacim {
                font-size: 32px;
                letter-spacing: 2px;
            }
            
            .focim {
                font-size: 20px;
            }
            
            .ikonok a {
                font-size: 18px;
            }
        }
    </style>
</head>
<body>

    <!-- navbar -->
    <div class="container-fluid">
        <div class="row navbar align-items-center">
            <div class="col-6 focim">
                <a href="?">D.A.T.M. Tuning műhely</a>
            </div>
            <div class="col-6 ikonok">
                <a href="kosar.php">
                    <i class="bi bi-cart3"></i>
                </a>
                <a href="#" data-bs-toggle="modal" data-bs-target="#profileModal">
                    <i class="bi bi-person-circle"></i>
                </a>
            </div>
        </div>
    </div>

    <!-- profilresz -->
    <div class="modal fade profile-modal" id="profileModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="bi bi-person-circle me-2"></i>Profilom</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="profile-avatar">
                        <i class="bi bi-person-fill"></i>
                    </div>
                    <div class="profile-name">
                        <?php echo isset($_SESSION['user_name']) ? htmlspecialchars($_SESSION['user_name']) : 'Vendég felhasználó'; ?>
                    </div>
                    <div class="profile-email">
                        <?php echo isset($_SESSION['user_email']) ? htmlspecialchars($_SESSION['user_email']) : 'vendeg@datm.hu'; ?>
                    </div>
                    <div class="mt-4">
                        <div class="profile-menu-item" id="writeOpinionBtn">
                            <i class="bi bi-pencil-square"></i>
                            <span>Vélemény írása</span>
                            <i class="bi bi-chevron-right"></i>
                        </div>
                        <div class="profile-menu-item logout-btn" id="logoutBtn">
                            <i class="bi bi-box-arrow-right"></i>
                            <span>Kijelentkezés</span>
                            <i class="bi bi-chevron-right"></i>
                        </div>
                        <div class="text-muted small mt-3 p-3 text-center border-top border-secondary">
                            <i class="bi bi-info-circle"></i> bejel/regiszt meg nincs kesz
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Bezárás</button>
                </div>
            </div>
        </div>
    </div>

    <!-- velemny -->
    <div class="modal fade opinion-modal" id="opinionModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="bi bi-star-fill me-2"></i>Írd meg véleményed</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="star-rating" id="starRating">
                        <i class="bi bi-star" data-rating="1"></i>
                        <i class="bi bi-star" data-rating="2"></i>
                        <i class="bi bi-star" data-rating="3"></i>
                        <i class="bi bi-star" data-rating="4"></i>
                        <i class="bi bi-star" data-rating="5"></i>
                    </div>
                    <textarea class="opinion-textarea" id="opinionText" rows="4" placeholder="Írd ide a véleményed..."></textarea>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Mégse</button>
                    <button type="button" class="btn btn-tuning" id="submitOpinionBtn">Vélemény elküldése</button>
                </div>
            </div>
        </div>
    </div>

    <!-- siker -->
    <div class="modal fade success-modal" id="successModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-sm">
            <div class="modal-content">
                <div class="modal-body text-center p-4">
                    <div class="success-icon">
                        <i class="bi bi-check-circle-fill"></i>
                    </div>
                    <h5 class="mb-3">Köszönjük!</h5>
                    <p class="mb-0">Véleményedet rögzítettük.</p>
                </div>
                <div class="modal-footer justify-content-center">
                    <button type="button" class="btn btn-tuning" data-bs-dismiss="modal">Rendben</button>
                </div>
            </div>
        </div>
    </div>

    <!-- oldal -->
    <div class="oldal">
        <div class="search-container">
            <input type="search" id="site-search" class="kereso" placeholder="Keresés...">
            <i class="bi bi-search keresoikon"></i>
        </div>
        <h3><i class="bi bi-grid me-2"></i>Márkák</h3>
        
        <?php
        if ($gyartok_result) $gyartok_result->data_seek(0);
        if ($gyartok_result && $gyartok_result->num_rows > 0) {
            while($gyarto = $gyartok_result->fetch_assoc()) {
                $is_active = ($selected_gyarto == $gyarto['id']);
                ?>
                <div class="gyarto-menu">
                    <div class="gyarto-fejlec <?php echo $is_active ? 'active' : ''; ?>" 
                         onclick="toggleGyarto(<?php echo $gyarto['id']; ?>)">
                        <span><i class="bi bi-tag me-2"></i><?php echo htmlspecialchars($gyarto['nev']); ?></span>
                        <i class="bi bi-chevron-right"></i>
                    </div>
                    <div class="kategoria-lista <?php echo $is_active ? 'show' : ''; ?>" id="kategoria-<?php echo $gyarto['id']; ?>">
                        <?php
                        if (!empty($kategoria_nevek)) {
                            foreach ($kategoria_nevek as $kat_id => $kat_nev) {
                                $is_kategoria_active = ($selected_kategoria == $kat_id && $is_active);
                                ?>
                                <a href="?gyarto=<?php echo $gyarto['id']; ?>&kategoria=<?php echo $kat_id; ?>" 
                                   class="<?php echo $is_kategoria_active ? 'active' : ''; ?>">
                                    <i class="bi bi-dot me-2"></i><?php echo htmlspecialchars($kat_nev); ?>
                                </a>
                                <?php
                            }
                        }
                        ?>
                    </div>
                </div>
                <?php
            }
        }
        ?>
    </div>

    <!-- main -->
    <div class="main">
        <div id="cim">
            <p class="markacim"><?php echo $selected_gyarto > 0 ? htmlspecialchars($gyarto_nev) : 'VÁLASSZ MÁRKÁT'; ?></p>
        </div>
        
        <?php if ($selected_gyarto > 0 && $selected_kategoria > 0 && !empty($kategoria_nev)): ?>
            <div class="kategoria-cim">
                <i class="bi bi-funnel-fill me-2"></i>
                Kiválasztott kategória: <span><?php echo htmlspecialchars($kategoria_nev); ?></span>
            </div>
        <?php endif; ?>
        
        <div class="row g-4 justify-content-center">
            <?php 
            if ($selected_gyarto > 0 && $selected_kategoria > 0 && !empty($kategoria_nev) && !empty($alkatreszek)) {
                foreach ($alkatreszek as $alkatresz) {
                    $item_id = base64_encode($alkatresz['motor_kod'] . $alkatresz['turbo_modell'] . ($alkatresz['alkalmassag'] ?? ''));
                    ?>
                    <div class="col-md-4">
                        <div class="kartya">
                            <i class="bi bi-turbo kartya-ikon"></i>
                            <h4><?php echo htmlspecialchars($alkatresz['motor_kod']); ?></h4>
                            <div class="kartya-adat">
                                <p><i class="bi bi-speedometer2"></i>Teljesítmény: <?php echo htmlspecialchars($alkatresz['loero']); ?> LE</p>
                                <p><i class="bi bi-cpu"></i>Hengerűrtartalom: <?php echo htmlspecialchars($alkatresz['hengerurtartalom']); ?> L</p>
                                <p><i class="bi bi-turbine"></i>Turbó: <?php echo htmlspecialchars($alkatresz['turbo_gyarto'] . ' ' . $alkatresz['turbo_modell']); ?></p>
                                <p><i class="bi bi-graph-up"></i>Tuning: <?php echo htmlspecialchars($alkatresz['teljesitmeny_tartomany_from'] . '-' . $alkatresz['teljesitmeny_tartomany_to']); ?> LE</p>
                                
                                <div class="d-flex justify-content-between align-items-center mt-3">
                                    <span class="badge-alkalmassag badge-<?php echo htmlspecialchars($alkatresz['alkalmassag'] ?? 'Performance'); ?>">
                                        <?php echo htmlspecialchars($alkatresz['alkalmassag'] ?? 'Performance'); ?>
                                    </span>
                                    
                                    <form method="POST" action="kosar.php">
                                        <input type="hidden" name="item_id" value="<?php echo $item_id; ?>">
                                        <input type="hidden" name="motor_kod" value="<?php echo htmlspecialchars($alkatresz['motor_kod']); ?>">
                                        <input type="hidden" name="loero" value="<?php echo htmlspecialchars($alkatresz['loero']); ?>">
                                        <input type="hidden" name="turbo" value="<?php echo htmlspecialchars($alkatresz['turbo_gyarto'] . ' ' . $alkatresz['turbo_modell']); ?>">
                                        <input type="hidden" name="alkalmassag" value="<?php echo htmlspecialchars($alkatresz['alkalmassag'] ?? 'Performance'); ?>">
                                        <button type="submit" name="add_to_cart" class="btn-add-to-cart">
                                            <i class="bi bi-cart-plus-fill"></i> Kosárba
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                    <?php
                }
                
                $talalatok_szama = count($alkatreszek);
                for ($i = $talalatok_szama; $i < 9; $i++) {
                    ?>
                    <div class="col-md-4">
                        <div class="kartya kartya-ures">
                            <i class="bi bi-plus-circle kartya-ikon"></i>
                            <p>Nincs több találat</p>
                            <small>Válassz másik kategóriát</small>
                        </div>
                    </div>
                    <?php
                }
            } else if ($selected_gyarto > 0 && $selected_kategoria > 0 && empty($alkatreszek)) {
                for ($i = 0; $i < 9; $i++) {
                    ?>
                    <div class="col-md-4">
                        <div class="kartya kartya-ures">
                            <i class="bi bi-search kartya-ikon"></i>
                            <p>Nincs találat</p>
                            <small>Ehhez a kategóriához nincs elérhető alkatrész</small>
                        </div>
                    </div>
                    <?php
                }
            } else {
                for ($i = 0; $i < 9; $i++) {
                    ?>
                    <div class="col-md-4">
                        <div class="kartya kartya-ures">
                            <i class="bi bi-box-seam kartya-ikon"></i>
                            <p>Üres</p>
                            <small>Válassz egy márkát és kategóriát</small>
                        </div>
                    </div>
                    <?php
                }
            }
            ?>
        </div>
    </div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function toggleGyarto(gyartoId) {
        window.location.href = '?gyarto=' + gyartoId;
    }
    
    document.addEventListener('DOMContentLoaded', function() {
        const writeOpinionBtn = document.getElementById('writeOpinionBtn');
        if (writeOpinionBtn) {
            writeOpinionBtn.addEventListener('click', function() {
                const profileModal = bootstrap.Modal.getInstance(document.getElementById('profileModal'));
                if (profileModal) profileModal.hide();
                resetStarRating();
                document.getElementById('opinionText').value = '';
                const opinionModal = new bootstrap.Modal(document.getElementById('opinionModal'));
                opinionModal.show();
            });
        }
        
        const logoutBtn = document.getElementById('logoutBtn');
        if (logoutBtn) {
            logoutBtn.addEventListener('click', function() {
                alert('Kijelentkezés funkció fejlesztés alatt');
                const profileModal = bootstrap.Modal.getInstance(document.getElementById('profileModal'));
                if (profileModal) profileModal.hide();
            });
        }
        
        const stars = document.querySelectorAll('#starRating i');
        let selectedRating = 0;
        
        stars.forEach(star => {
            star.addEventListener('click', function() {
                selectedRating = parseInt(this.getAttribute('data-rating'));
                updateStars(selectedRating);
            });
            star.addEventListener('mouseenter', function() {
                const rating = parseInt(this.getAttribute('data-rating'));
                previewStars(rating);
            });
            star.addEventListener('mouseleave', function() {
                previewStars(selectedRating);
            });
        });
        
        function updateStars(rating) {
            stars.forEach(star => {
                const starRating = parseInt(star.getAttribute('data-rating'));
                star.className = starRating <= rating ? 'bi bi-star-fill' : 'bi bi-star';
            });
        }
        
        function previewStars(rating) {
            stars.forEach(star => {
                const starRating = parseInt(star.getAttribute('data-rating'));
                star.className = starRating <= rating ? 'bi bi-star-fill' : 'bi bi-star';
            });
        }
        
        function resetStarRating() {
            selectedRating = 0;
            stars.forEach(star => star.className = 'bi bi-star');
        }
        
        const submitOpinionBtn = document.getElementById('submitOpinionBtn');
        if (submitOpinionBtn) {
            submitOpinionBtn.addEventListener('click', function() {
                const opinionText = document.getElementById('opinionText').value;
                console.log('Vélemény:', opinionText);
                console.log('Értékelés:', selectedRating);
                
                const opinionModal = bootstrap.Modal.getInstance(document.getElementById('opinionModal'));
                if (opinionModal) opinionModal.hide();
                
                const successModal = new bootstrap.Modal(document.getElementById('successModal'));
                successModal.show();
                
                setTimeout(function() {
                    const successModalInstance = bootstrap.Modal.getInstance(document.getElementById('successModal'));
                    if (successModalInstance) successModalInstance.hide();
                }, 2000);
            });
        }
    });
</script>

</body>
</html>

<?php
$mysqli->close();
?>
