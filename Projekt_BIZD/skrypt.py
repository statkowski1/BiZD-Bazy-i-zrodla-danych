import os
import shutil
import pandas as pd
import cx_Oracle
import oracledb

DB_USER = "tatkowskis"
DB_PASSWORD = "Haczyk448319"
DB_DSN = "213.184.8.44:1521/orcl"
DB_HOST = "213.184.8.44"
DB_PORT = "1521"
DB_SID = "orcl"
DSN = oracledb.makedsn(DB_HOST, DB_PORT, DB_SID)
CSV_DIR = "dane"
ARCHIVE_DIR = "archiwum"

def sprawdz_dane(df, tabela):
    if tabela == "Loty":
        wymagane_kolumny = ["id_lotu", "numer_lotu", "skad", "dokad", "data_odlotu", "data_przylotu", "status_lotu"]
    elif tabela == "Pasażerowie":
        wymagane_kolumny = ["id_pasażera", "imie", "nazwisko", "paszport", "narodowość", "data_urodzenia"]
    elif tabela == "Rezerwacje":
        wymagane_kolumny = ["id_rezerwacji", "id_pasażera", "id_lotu", "miejsce", "klasa"]
    elif tabela == "Pracownicy":
        wymagane_kolumny = ["id_pracownika", "imie", "nazwisko", "stanowisko", "pensja", "data_zatrudnienia"]
    elif tabela == "Samoloty":
        wymagane_kolumny = ["id_samolotu", "model", "producent", "liczba_miejsc", "data_produkcji", "status"]
    elif tabela == "ObsługaTechniczna":
        wymagane_kolumny = ["id_obsługi", "id_samolotu", "data_konserwacji", "opis", "koszt"]
    elif tabela == "Bramki":
        wymagane_kolumny = ["id_bramki", "numer_bramki", "terminal", "status"]
    elif tabela == "Przydziały":
        wymagane_kolumny = ["id_przydziału", "id_lotu", "id_bramki", "czas_od", "czas_do"]
    else:
        raise ValueError(f"Nieznana tabela: {tabela}")

    for kolumna in wymagane_kolumny:
        if kolumna not in df.columns:
            raise ValueError(f"Brakuje kolumny: {kolumna}")
    return True

def laduj_dane(csv_file, tabela):
    try:
        df = pd.read_csv(csv_file)

        df.columns = df.columns.str.strip()

        if 'data_odlotu' in df.columns:
            df['data_odlotu'] = pd.to_datetime(df['data_odlotu'])
        if 'data_przylotu' in df.columns:
            df['data_przylotu'] = pd.to_datetime(df['data_przylotu'])

        sprawdz_dane(df, tabela)

        conn = oracledb.connect(user=DB_USER, password=DB_PASSWORD, dsn=DSN)
        cursor = conn.cursor()

        for index, row in df.iterrows():
            columns = ', '.join(df.columns)
            placeholders = ', '.join([f":{i}" for i in range(1, len(row) + 1)])
            values = [val if not pd.isna(val) else None for val in row]

            sql = f"INSERT INTO {tabela} ({columns}) VALUES ({placeholders})"

            cursor.execute(sql, {f":{i}": val for i, val in enumerate(values, start=1)})

        conn.commit()
        cursor.close()
        conn.close()

        print(f"Pomyślnie załadowano dane z {csv_file} do tabeli {tabela}.")
    except Exception as e:
        print(f"Błąd podczas ładowania danych z {csv_file}: {e}")

def archiwizuj_plik(csv_file):
    if not os.path.exists(ARCHIVE_DIR):
        os.makedirs(ARCHIVE_DIR)
    shutil.move(csv_file, os.path.join(ARCHIVE_DIR, os.path.basename(csv_file)))
    print(f"Zarchiwizowano plik: {csv_file}")

def main():
    for file in os.listdir(CSV_DIR):
        if file.endswith(".csv"):
            csv_file = os.path.join(CSV_DIR, file)

            if "loty" in file.lower():
                tabela = "Loty"
            elif "pasazerowie" in file.lower():
                tabela = "Pasażerowie"
            elif "rezerwacje" in file.lower():
                tabela = "Rezerwacje"
            elif "pracownicy" in file.lower():
                tabela = "Pracownicy"
            elif "samoloty" in file.lower():
                tabela = "Samoloty"
            elif "obslugatechniczna" in file.lower():
                tabela = "ObsługaTechniczna"
            elif "bramki" in file.lower():
                tabela = "Bramki"
            elif "przydzialy" in file.lower():
                tabela = "Przydziały"
            else:
                print(f"Nieznany typ pliku: {file}")
                continue

            laduj_dane(csv_file, tabela)
            archiwizuj_plik(csv_file)

if __name__ == "__main__":
    main()
