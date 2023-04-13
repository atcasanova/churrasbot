distance(){
    local lat1 lon1 lat2 lon2 a d r=6378140 pi=3.14159265358979323846
    lat1=$(echo "scale=20; $1 * ($pi / 180)" | bc -l)
    lon1=$(echo "scale=20; $2 * ($pi / 180)" | bc -l)
    lat2=$(echo "scale=20; $3 * ($pi / 180)" | bc -l)
    lon2=$(echo "scale=20; $4 * ($pi / 180)" | bc -l)

    # Fórmula de Haversine
    a=$(echo "scale=20; s((($lat2 - $lat1) / 2))^2 + c($lat1) * c($lat2) * s(($lon2 - $lon1) / 2)^2" | bc -l)
    d=$(echo "scale=20; 2 * a(sqrt($a))" | bc -l)

    # Distância em metros, sem casas decimais
    distance=$(echo "scale=6; $r * $d " | bc)
    echo "[+] DISTANCE distância calculada: ${distance}"
    distance=${distance%\.*}
}
