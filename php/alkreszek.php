<?php
session_start();

// Adatbázis kapcsolat
$user = 'root';
$password = '';
$database = 'turbo_adatbazis';
$servername = 'localhost';

$mysqli = new mysqli($servername, $user, $password, $database);

if ($mysqli->connect_error) {
    die('Connect Error (' . $mysqli->connect_errno . ') ' . $mysqli->connect_error);
}

// Gyártók lekérése
$gyartok_sql = "SELECT id, nev FROM autogyartok ORDER BY nev";
$gyartok_result = $mysqli->query($gyartok_sql);

// Kategóriák lekérése
$kategoriak_sql = "SELECT id, kat_nev, leiras FROM kategoriak ORDER BY kat_nev";
$kategoriak_result = $mysqli->query($kategoriak_sql);

// Kiválasztott gyártó és kategória kezelése
$selected_gyarto = isset($_GET['gyarto']) ? (int)$_GET['gyarto'] : 0;
$selected_kategoria = isset($_GET['kategoria']) ? (int)$_GET['kategoria'] : 0;

// Alkartészek lekérése a kiválasztott gyártóhoz és kategóriához
$alkatreszek = [];
if ($selected_gyarto > 0 && $selected_kategoria > 0) {
    // Itt lehet összetett lekérdezés a motorokhoz és turbókhoz
    // Most egy egyszerű példa lekérdezés
    $alkatresz_sql = "SELECT 
                        m.motor_kod,
                        m.loero,
                        m.hengerurtartalom,
                        t.modell AS turbo_modell,
                        tg.nev AS turbo_gyarto,
                        mtk.alkalmassag,
                        mtk.teljesitmeny_tartomany_from,
                        mtk.teljesitmeny_tartomany_to
                      FROM motor_turbo_kapcsolat mtk
                      JOIN motorok m ON mtk.motor_id = m.id
                      JOIN motorcsaladok mc ON m.motorcsalad_id = mc.id
                      JOIN autogyartok ag ON mc.gyarto_id = ag.id
                      JOIN turbok t ON mtk.turbo_id = t.id
                      JOIN turbo_gyartok tg ON t.turbo_gyarto_id = tg.id
                      WHERE ag.id = ? 
                      AND mtk.alkalmassag = (SELECT kat_nev FROM kategoriak WHERE id = ?)
                      LIMIT 9"; // max 9 találat a 3x3-as rács miatt
    
    $stmt = $mysqli->prepare($alkatresz_sql);
    if ($stmt) {
        $stmt->bind_param("ii", $selected_gyarto, $selected_kategoria);
        $stmt->execute();
        $alkatreszek_result = $stmt->get_result();
        $alkatreszek = $alkatreszek_result->fetch_all(MYSQLI_ASSOC);
        $stmt->close();
    }
}

// Gyártó nevének lekérése a címsorhoz
$gyarto_nev = '';
if ($selected_gyarto > 0) {
    $gyarto_sql = "SELECT nev FROM autogyartok WHERE id = ?";
    $stmt = $mysqli->prepare($gyarto_sql);
    $stmt->bind_param("i", $selected_gyarto);
    $stmt->execute();
    $gyarto_result = $stmt->get_result();
    if ($gyarto_row = $gyarto_result->fetch_assoc()) {
        $gyarto_nev = $gyarto_row['nev'];
    }
    $stmt->close();
}
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
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            overflow-x: hidden;
            background-color: #f5f5f5;

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
            color: black;
        }
        
        .ikonok {
            font-size: 34px;
            margin-right: -18vh;
        }

        .ikonok a {
            text-decoration: none;
            color: black;
        }

        .ikkon {
            height: 30px;
            width: 30px;
            margin-left: 15px;
            margin-right: 15px;
        }

        .ikkon:hover {
            color: rgb(255, 255, 255);
        }

        .navbar {
            background-color: rgb(214, 214, 214);
            position: fixed;
            top: 0;
            width: 100%;
            z-index: 1000;
            height:8.7%;
        }
        
        #cim {
            margin-top: 100px;
            margin-bottom: 40px;
            text-align: center;    
            font-size: 7.2vh;   
            letter-spacing: 4vh;
            padding: 20px 0;
        }
        
        .kartya {
            background-color: #7E354D; 
            background-image: radial-gradient(circle, #B32134 0%, #7C0A02 100%);
            box-shadow: inset 0 0 50px rgba(0, 0, 0, 0.5);

            color: white;
            min-height: 200px;
            margin-bottom: 20px;
            border-radius: 15px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            font-size: 16px;
            font-weight: bold;
            padding: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            transition: transform 0.3s, box-shadow 0.3s;
            cursor: pointer;
        }
        
        .kartya:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 40px rgba(0,0,0,0.3);
        }
        
        .kartya-ikon {
            font-size: 48px;
            margin-bottom: 15px;
        }
        
        .kartya-ures {
            background-color: #7E354D; 
            background-image: radial-gradient(circle, #B32134 0%, #7C0A02 100%);
            box-shadow: inset 0 0 50px rgba(0, 0, 0, 0.5);
            font-size: 18px;
        }
        
        .kartya-adat {
            width: 100%;
            text-align: left;
            margin-top: 10px;
        }
        
        .kartya-adat p {
            margin: 5px 0;
            font-size: 14px;
            border-bottom: 1px solid rgba(255,255,255,0.2);
            padding-bottom: 5px;
        }
        
        .Ksor {
            gap: 20px;
            margin-bottom: 20px;
        }

        .oldal {
            height: calc(100vh - 8.7%);
            width: 250px;
            position: fixed;
            z-index: 900;
            top: 80px;
            left: 0;
            background-color: #2c3e50;
            overflow-y: auto;
            padding: 20px 0;
            box-shadow: 2px 0 10px rgba(0,0,0,0.1);
        }
        
        .oldal a {
            padding: 12px 20px;
            text-decoration: none;
            font-size: 16px;
            color: #ecf0f1;
            display: block;
            transition: all 0.3s;
            border-left: 4px solid transparent;
        }
        
        .oldal a:hover {
            background-color: #34495e;
            border-left-color: #e74c3c;
            color: white;
        }
        
        .oldal a.active {
            background-color: #943c5a; 
            background-image: radial-gradient(circle, #c42a3f 0%, #a31409 100%);
            box-shadow: inset 0 0 50px rgba(0, 0, 0, 0.5);
            color: white;
        }

        .oldal h3 {
            color:#f11e3a;
            padding: 0 20px;
            margin: 20px 0 10px;
            font-size: 18px;
            text-transform: uppercase;
            letter-spacing: 2px;
            font-weight: bolder;
        }
        /*
        .main {
            margin-left: 250px;
            padding: 20px 30px;
            background-image: url("../Kepek/honda.jpg");
            background-attachment: fixed;
            background-position-x: right;
            background-color: #af1106;
            background-repeat: no-repeat;
        }
        */
        .main {
            margin-left: 250px;
            padding: 20px 30px;
            padding-top: 10px;
            
            background: 
                url('../Kepek/honda.jpg') no-repeat right center / contain, 
                linear-gradient(135deg, #BA0C01 0%, #2E0B09 100%);
    
                /* Az illesztés elmosása, hogy ne legyen éles vonal a kép széle és az átmenet között */
                position: relative;
                background-size: contain, cover;
        }
        .main::before{
            content: '';
            position: absolute;
            right: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(to right, rgba(186, 12, 1, 0) 60%, rgba(46, 11, 9, 0.1) 100%);
            pointer-events: none;
        }

        .search-container {
            padding: 0 20px 20px;
            display: flex;
            align-items: center;
        }

        .kereso {
            border-radius: 20px;
            width: 160px;
            padding: 8px 15px;
            border: none;
            background-color: #34495e;
            color: white;
        }
        
        .kereso::placeholder {
            color: #95a5a6;
        }

        .keresoikon {
            margin-left: 10px;
            color: #ecf0f1;
            height: 20px;
            width: 20px;
        }
        
        .gyarto-menu {
            margin-bottom: 5px;
        }
        
        .gyarto-fejlec {
            cursor: pointer;
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 20px;
            color: #ecf0f1;
            transition: all 0.3s;
            border-left: 4px solid transparent;
        }
        
        .gyarto-fejlec:hover {
            background-color: #34495e;
            border-left-color: #e74c3c;
        }
        
        .gyarto-fejlec.active {
            background-color: #7c0e1d; 
            background-image: radial-gradient(circle, #a8071d 0%, #4e0b07 100%);
            box-shadow: inset 0 0 50px rgba(0, 0, 0, 0.5);;
        }
        
        .gyarto-fejlec i {
            transition: transform 0.3s;
        }
        
        .gyarto-fejlec.open i {
            transform: rotate(90deg);
        }
        
        .kategoria-lista {
            display: none;
            background-color: #1e2b37;
            padding: 5px 0;
        }
        
        .kategoria-lista.show {
            display: block;
        }
        
        .kategoria-lista a {
            padding-left: 40px;
            font-size: 14px;
            color: #bdc3c7;
        }
        
        .kategoria-lista a:hover {
            background-color: #2c3e50;
            color: white;
        }
        
        .kategoria-lista a.active {
            background-color: #2980b9;
            color: white;
        }
        
        .info-ikon {
            font-size: 12px;
            margin-right: 5px;
            color: #f1c40f;
        }
        
        .kategoria-cim {
            margin: 20px 0;
            color: #2c3e50;
            font-size: 24px;
            font-weight: bold;
        }
        
        .kategoria-cim span {
            color: #3498db;
        }
        
        .badge-alkalmassag {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 15px;
            font-size: 12px;
            font-weight: normal;
            margin-top: 5px;
        }
        
        .badge-Gyári { background-color: #27ae60; color: white; }
        .badge-Performance { background-color: #2980b9; color: white; }
        .badge-Verseny { background-color: #e74c3c; color: white; }
        .badge-Drag { background-color: #8e44ad; color: white; }
        .badge-Daily { background-color: #f39c12; color: white; }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row navbar align-items-center py-2">
            <div class="col-9 focim">
                <a href="?">D.A.T.M. Tuning műhely</a>
            </div>
            <div class="col-3 ikonok d-flex">
                <a href="#">
                    <i class="bi bi-moon-stars ikkon"></i>
                </a>
                <a href="#">
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
    
    <div class="oldal">
        <div class="search-container">
            <input type="search" id="site-search" class="kereso" name="q" placeholder="Keresés..."/>
            <i class="bi bi-search keresoikon"></i>
        </div>
        
        <h3><i class="bi bi-grid me-2"></i>Márkák</h3>
        
        <?php
        if ($gyartok_result && $gyartok_result->num_rows > 0) {
            while($gyarto = $gyartok_result->fetch_assoc()) {
                $is_active = ($selected_gyarto == $gyarto['id']);
                $has_submenu = $is_active; // Csak a kiválasztott gyártónál nyitjuk ki
                ?>
                <div class="gyarto-menu">
                    <div class="gyarto-fejlec <?php echo $is_active ? 'active' : ''; ?> <?php echo $has_submenu ? 'open' : ''; ?>" 
                         onclick="toggleGyarto(<?php echo $gyarto['id']; ?>)">
                        <span><i class="bi bi-tag me-2"></i><?php echo htmlspecialchars($gyarto['nev']); ?></span>
                        <i class="bi bi-chevron-right"></i>
                    </div>
                    <div class="kategoria-lista <?php echo $is_active ? 'show' : ''; ?>" id="kategoria-<?php echo $gyarto['id']; ?>">
                        <?php
                        // Kategóriák listázása ehhez a gyártóhoz
                        $kategoriak_result->data_seek(0); // Visszaállítjuk a pointert
                        if ($kategoriak_result && $kategoriak_result->num_rows > 0) {
                            while($kategoria = $kategoriak_result->fetch_assoc()) {
                                $is_kategoria_active = ($selected_kategoria == $kategoria['id'] && $is_active);
                                ?>
                                <a href="?gyarto=<?php echo $gyarto['id']; ?>&kategoria=<?php echo $kategoria['id']; ?>" 
                                   class="<?php echo $is_kategoria_active ? 'active' : ''; ?>">
                                    <i class="bi bi-dot me-2"></i><?php echo htmlspecialchars($kategoria['kat_nev']); ?>
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
    
    <div class="main">
        <div id="cim">
            <p><?php echo $selected_gyarto > 0 ? htmlspecialchars($gyarto_nev) : 'VÁLASSZ MÁRKÁT'; ?></p>
        </div>
        
        <?php if ($selected_gyarto > 0 && $selected_kategoria > 0): ?>
            <div class="kategoria-cim">
                <i class="bi bi-funnel-fill me-2"></i>
                Kiválasztott kategória: <span><?php 
                    $kategoriak_result->data_seek(0);
                    while($kat = $kategoriak_result->fetch_assoc()) {
                        if ($kat['id'] == $selected_kategoria) {
                            echo htmlspecialchars($kat['kat_nev']);
                            break;
                        }
                    }
                ?></span>
            </div>
        <?php endif; ?>
        
        <div class="text-center">
            <div class="row Ksor justify-content-md-center">
                <?php 
                if ($selected_gyarto > 0 && $selected_kategoria > 0 && !empty($alkatreszek)) {
                    // Megjelenítjük a találatokat
                    foreach ($alkatreszek as $alkatresz) {
                        ?>
                        <div class="col-md-4">
                            <div class="kartya">
                                <i class="bi bi-turbo kartya-ikon"></i>
                                <h4><?php echo htmlspecialchars($alkatresz['motor_kod']); ?></h4>
                                <div class="kartya-adat">
                                    <p><i class="bi bi-speedometer2 me-2"></i>Teljesítmény: <?php echo $alkatresz['loero']; ?> LE</p>
                                    <p><i class="bi bi-cpu me-2"></i>Hengerűrtartalom: <?php echo $alkatresz['hengerurtartalom']; ?> L</p>
                                    <p><i class="bi bi-turbine me-2"></i>Turbó: <?php echo htmlspecialchars($alkatresz['turbo_gyarto'] . ' ' . $alkatresz['turbo_modell']); ?></p>
                                    <p><i class="bi bi-graph-up me-2"></i>Tuning: <?php echo $alkatresz['teljesitmeny_tartomany_from']; ?>-<?php echo $alkatresz['teljesitmeny_tartomany_to']; ?> LE</p>
                                    <span class="badge-alkalmassag badge-<?php echo $alkatresz['alkalmassag']; ?>">
                                        <?php echo $alkatresz['alkalmassag']; ?>
                                    </span>
                                </div>
                            </div>
                        </div>
                        <?php
                    }
                    
                    // Ha kevesebb mint 9 találat van, a többit üresen hagyjuk
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
                } else {
                    // Alapértelmezett üres kártyák
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
    </div>

    <script>
        function toggleGyarto(gyartoId) {
            // Átirányítás a gyártó kiválasztásához
            window.location.href = '?gyarto=' + gyartoId;
        }
        
        // Ha van kiválasztott gyártó, görgessünk hozzá
        window.onload = function() {
            <?php if ($selected_gyarto > 0): ?>
            const activeElement = document.querySelector('.gyarto-fejlec.active');
            if (activeElement) {
                activeElement.scrollIntoView({behavior: 'smooth', block: 'center'});
            }
            <?php endif; ?>
        };
    </script>
</body>
</html>

<?php
$mysqli->close();
?>
