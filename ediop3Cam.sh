#!/bin/bash

echo -e "\033[1;34m"
cat << "EOF"
  ___  _  _  ___  ___  ___   ___   ___ 
 | __|| \| || _ \| _ \| _ \ / _ \ / __|
 | _| | .  ||  _/|  _/|  _/| (_) |\__ \
 |___||_|\_||_|  |_|  |_|   \___/ |___/
EOF
echo -e "\033[0m"

if ! command -v python3 &> /dev/null; then
    echo -e "\033[1;31mError: Python3 is required but not installed.\033[0m"
    exit 1
fi

TMP_SCRIPT="ediop3Cam_temp.py"

cat << 'PYTHON_SCRIPT' > $TMP_SCRIPT
#!/usr/bin/env python3
import sys
import requests
import re
import time
import os
from colorama import init, Fore, Back, Style

init(autoreset=True)

def print_banner():
    print(Fore.BLUE + """
  ___  _  _  ___  ___  ___   ___   ___ 
 | __|| \| || _ \| _ \| _ \ / _ \ / __|
 | _| | .  ||  _/|  _/|  _/| (_) |\__ \\
 |___||_|\_||_|  |_|  |_|   \___/ |___/
    """)
    print(Fore.RED + "ediop3Cam")
    print(Style.RESET_ALL)

def loading_animation():
    for i in range(5):
        for char in "|/-\\":
            sys.stdout.write(Fore.BLUE + "\rLoading " + char + " " + Fore.RED + "Please wait..." + Style.RESET_ALL)
            sys.stdout.flush()
            time.sleep(0.1)
    print("\n")

def print_country_list():
    countries = [
        ("1", "United States"), ("2", "Japan"), ("3", "Italy"), ("4", "Korea"), ("5", "France"),
        ("6", "Germany"), ("7", "Taiwan"), ("8", "Russian Federation"), ("9", "United Kingdom"), ("10", "Netherlands"),
        ("11", "Czech Republic"), ("12", "Turkey"), ("13", "Austria"), ("14", "Switzerland"), ("15", "Spain"),
        ("16", "Canada"), ("17", "Sweden"), ("18", "Israel"), ("19", "Iran"), ("20", "Poland"),
        ("21", "India"), ("22", "Norway"), ("23", "Romania"), ("24", "Viet Nam"), ("25", "Belgium"),
        ("26", "Brazil"), ("27", "Bulgaria"), ("28", "Indonesia"), ("29", "Denmark"), ("30", "Argentina"),
        ("31", "Mexico"), ("32", "Finland"), ("33", "China"), ("34", "Chile"), ("35", "South Africa"),
        ("36", "Slovakia"), ("37", "Hungary"), ("38", "Ireland"), ("39", "Egypt"), ("40", "Thailand"),
        ("41", "Ukraine"), ("42", "Serbia"), ("43", "Hong Kong"), ("44", "Greece"), ("45", "Portugal"),
        ("46", "Latvia"), ("47", "Singapore"), ("48", "Iceland"), ("49", "Malaysia"), ("50", "Colombia"),
        ("51", "Tunisia"), ("52", "Estonia"), ("53", "Dominican Republic"), ("54", "Sloveania"), ("55", "Ecuador"),
        ("56", "Lithuania"), ("57", "Palestinian"), ("58", "New Zealand"), ("59", "Bangladeh"), ("60", "Panama"),
        ("61", "Moldova"), ("62", "Nicaragua"), ("63", "Malta"), ("64", "Trinidad And Tobago"), ("65", "Soudi Arabia"),
        ("66", "Croatia"), ("67", "Cyprus"), ("68", "Pakistan"), ("69", "United Arab Emirates"), ("70", "Kazakhstan"),
        ("71", "Kuwait"), ("72", "Venezuela"), ("73", "Georgia"), ("74", "Montenegro"), ("75", "El Salvador"),
        ("76", "Luxembourg"), ("77", "Curacao"), ("78", "Puerto Rico"), ("79", "Costa Rica"), ("80", "Belarus"),
        ("81", "Albania"), ("82", "Liechtenstein"), ("83", "Bosnia And Herzegovia"), ("84", "Paraguay"), ("85", "Philippines"),
        ("86", "Faroe Islands"), ("87", "Guatemala"), ("88", "Nepal"), ("89", "Peru"), ("90", "Uruguay"),
        ("91", "Extra"), ("92", "Andorra"), ("93", "Antigua And Barbuda"), ("94", "Armenia"), ("95", "Angola"),
        ("96", "Australia"), ("97", "Aruba"), ("98", "Azerbaijan"), ("99", "Barbados"), ("100", "Bonaire")
    ]
    
    print(Fore.YELLOW + "\nCountry List:")
    for i in range(0, len(countries), 3):
        line = ""
        for j in range(3):
            if i+j < len(countries):
                num, name = countries[i+j]
                line += f"{Fore.RED}{num.rjust(3)}{Fore.RESET} {Fore.BLUE}{name.ljust(25)}{Fore.RESET}"
        print(line)

def get_country_code(num):
    country_codes = [
        "US", "JP", "IT", "KR", "FR", "DE", "TW", "RU", "GB", "NL",
        "CZ", "TR", "AT", "CH", "ES", "CA", "SE", "IL", "PL", "IR",
        "NO", "RO", "IN", "VN", "BE", "BR", "BG", "ID", "DK", "AR",
        "MX", "FI", "CN", "CL", "ZA", "SK", "HU", "IE", "EG", "TH",
        "UA", "RS", "HK", "GR", "PT", "LV", "SG", "IS", "MY", "CO",
        "TN", "EE", "DO", "SI", "EC", "LT", "PS", "NZ", "BD", "PA",
        "MD", "NI", "MT", "TT", "SA", "HR", "CY", "PK", "AE", "KZ",
        "KW", "VE", "GE", "ME", "SV", "LU", "CW", "PR", "CR", "BY",
        "AL", "LI", "BA", "PY", "PH", "FO", "GT", "NP", "PE", "UY",
        "-", "AD", "AG", "AM", "AO", "AU", "AW", "AZ", "BB", "BQ",
        "BS", "BW", "CG", "CI", "DZ", "FJ", "GA", "GG", "GL", "GP",
        "GU", "GY", "HN", "JE", "JM", "JO", "KE", "KH", "KN", "KY",
        "LA", "LB", "LK", "MA", "MG", "MK", "MN", "MO", "MQ", "MU"
    ]
    return country_codes[num-1] if 1 <= num <= 100 else None

def main():
    print_banner()
    loading_animation()
    print_country_list()
    
    try:
        num = int(input(Fore.GREEN + "\nEnter country number (1-100): " + Fore.RESET))
        if num < 1 or num > 100:
            print(Fore.RED + "Invalid number. Please enter between 1-100.")
            return
        
        country_code = get_country_code(num)
        if not country_code:
            print(Fore.RED + "Invalid country code.")
            return
        
        print(Fore.YELLOW + f"\nSearching cameras in country #{num}..." + Fore.RESET)
        
        headers = {"User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"}
        url = f"http://www.insecam.org/en/bycountry/{country_code}"
        
        try:
            res = requests.get(url, headers=headers, timeout=10)
            res.raise_for_status()
            
            last_page_match = re.findall(r'pagenavigator\("\?page=", (\d+)', res.text)
            if not last_page_match:
                print(Fore.RED + "No cameras found or unable to parse pages.")
                return
            
            last_page = int(last_page_match[0])
            print(Fore.CYAN + f"Found {last_page} pages of results." + Fore.RESET)
            
            for page in range(1, min(last_page, 200000) + 1):
                page_url = f"{url}/?page={page}"
                try:
                    page_res = requests.get(page_url, headers=headers, timeout=10)
                    page_res.raise_for_status()
                    
                    ip_pattern = r"http://\d+\.\d+\.\d+\.\d+:\d+"
                    ip_matches = re.findall(ip_pattern, page_res.text)
                    
                    if not ip_matches:
                        print(Fore.YELLOW + f"No IPs found on page {page}.")
                        continue
                    
                    print(Fore.GREEN + f"\nPage {page} results:" + Fore.RESET)
                    for ip in ip_matches:
                        if ip_matches.index(ip) % 2 == 0:
                            print(Fore.BLUE + ip)
                        else:
                            print(Fore.RED + ip)
                    
                    time.sleep(1)
                    
                except requests.RequestException as e:
                    print(Fore.RED + f"Error fetching page {page}: {e}")
                    continue
            
        except requests.RequestException as e:
            print(Fore.RED + f"Error connecting to insecam.org: {e}")
        
    except ValueError:
        print(Fore.RED + "Please enter a valid number.")
    except KeyboardInterrupt:
        print(Fore.YELLOW + "\nOperation cancelled by user.")
    except Exception as e:
        print(Fore.RED + f"An unexpected error occurred: {e}")

if __name__ == "__main__":
    main()
PYTHON_SCRIPT

python3 $TMP_SCRIPT

rm -f $TMP_SCRIPT
