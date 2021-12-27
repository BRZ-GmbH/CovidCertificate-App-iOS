// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable function_parameter_count identifier_name line_length type_body_length
 enum UBLocalized {
   enum UBLocalizedKey : String {
    /// Kamera ist Aktiv
     case accessibility_active_camera_key = "accessibility_active_camera"
    /// Zertifikat hinzufügen
     case accessibility_add_button_key = "accessibility_add_button"
    /// Ungültig
     case accessibility_certificate_list_in_valid_key = "accessibility_certificate_list_in_valid"
    /// Gültig
     case accessibility_certificate_list_valid_key = "accessibility_certificate_list_valid"
    /// Zum Ändern Doppeltippen
     case accessibility_change_selected_region_key = "accessibility_change_selected_region"
    /// Schliessen
     case accessibility_close_button_key = "accessibility_close_button"
    /// Für die Detailansicht Doppeltippen
     case accessibility_detail_certificate_key = "accessibility_detail_certificate"
    /// Öffnet in neuem Fenster
     case accessibility_external_link_key = "accessibility_external_link"
    /// Häufige Fragen
     case accessibility_faq_button_key = "accessibility_faq_button"
    /// Kamera ist nicht mehr Aktiv
     case accessibility_in_active_camera_key = "accessibility_in_active_camera"
    /// Information
     case accessibility_info_box_key = "accessibility_info_box"
    /// Impressum
     case accessibility_info_button_key = "accessibility_info_button"
    /// Taschenlampe ausschalten
     case accessibility_lamp_off_button_key = "accessibility_lamp_off_button"
    /// Taschenlampe einschalten
     case accessibility_lamp_on_button_key = "accessibility_lamp_on_button"
    /// Liste Ihrer Zertifikate
     case accessibility_list_button_key = "accessibility_list_button"
    /// von
     case accessibility_of_text_key = "accessibility_of_text"
    /// Seite
     case accessibility_page_control_page_key = "accessibility_page_control_page"
    /// Aktiv
     case accessibility_region_active_key = "accessibility_region_active"
    /// Zum Ändern Doppeltippen
     case accessibility_region_in_active_key = "accessibility_region_in_active"
    /// Aktuelle Region
     case accessibility_selected_region_key = "accessibility_selected_region"
    /// Zugriff auf Kamera erlauben
     case camera_permission_dialog_action_key = "camera_permission_dialog_action"
    /// Die App benötigt Zugriff auf die Kamera, um den QR-Code scannen zu können.
     case camera_permission_dialog_text_key = "camera_permission_dialog_text"
    /// Abbrechen
     case cancel_button_key = "cancel_button"
    /// QR Code, Bild
     case certificate_details_qr_icon_key = "certificate_details_qr_icon"
    /// Genesung
     case certificate_reason_recovered_key = "certificate_reason_recovered"
    /// Test
     case certificate_reason_tested_key = "certificate_reason_tested"
    /// Impfung
     case certificate_reason_vaccinated_key = "certificate_reason_vaccinated"
    /// Schliessen
     case close_button_key = "close_button"
    /// Weiter
     case continue_button_key = "continue_button"
    /// Genesung
     case covid_certificate_recovery_title_key = "covid_certificate_recovery_title"
    /// Test
     case covid_certificate_test_title_key = "covid_certificate_test_title"
    /// EU-konformes Zertifikat
     case covid_certificate_title_key = "covid_certificate_title"
    /// Impfung
     case covid_certificate_vaccination_title_key = "covid_certificate_vaccination_title"
    /// Löschen
     case delete_button_key = "delete_button"
    /// Einstellungen ändern
     case error_action_change_settings_key = "error_action_change_settings"
    /// Erneut versuchen
     case error_action_retry_key = "error_action_retry"
    /// Die App benötigt Zugriff auf die Kamera, um das Zertifikat scannen zu können.
     case error_camera_permission_text_key = "error_camera_permission_text"
    /// Kein Zugriff auf Kamera
     case error_camera_permission_title_key = "error_camera_permission_title"
    /// Überprüfen Sie Ihre Internet Verbindung.
     case error_network_text_key = "error_network_text"
    /// Netzwerkfehler
     case error_network_title_key = "error_network_title"
    /// Fehler
     case error_title_key = "error_title"
    /// Aktualisieren
     case force_update_button_key = "force_update_button"
    /// Jetzt nicht
     case force_update_grace_period_skip_button_key = "force_update_grace_period_skip_button"
    /// Bitte laden Sie vor %@ die neueste Version der App.
     case force_update_grace_period_text_key = "force_update_grace_period_text"
    /// Update benötigt
     case force_update_grace_period_title_key = "force_update_grace_period_title"
    /// Aktualisieren
     case force_update_grace_period_update_button_key = "force_update_grace_period_update_button"
    /// Laden Sie die neue Version der App.
     case force_update_text_key = "force_update_text"
    /// Update benötigt
     case force_update_title_key = "force_update_title"
    /// Impressum
     case impressum_title_key = "impressum_title"
    /// Einstellungen
     case ios_settings_open_key = "ios_settings_open"
    /// de
     case language_key_key = "language_key"
    /// Die App benötigt Zugriff auf die Kamera, um den EU-konformen QR-Code scannen zu können.
     case NSCameraUsageDescription_key = "NSCameraUsageDescription"
    /// OK
     case ok_button_key = "ok_button"
    /// Kein gültiger Code
     case qr_scanner_error_key = "qr_scanner_error"
    /// Burgenland
     case region_burgenland_key = "region_burgenland"
    /// Kärnten
     case region_kaernten_key = "region_kaernten"
    /// Bundesweit
     case region_nationwide_key = "region_nationwide"
    /// Bundesweit\n(exkl. Wien)
     case region_nationwide_validity_key = "region_nationwide_validity"
    /// Niederösterreich
     case region_niederoesterreich_key = "region_niederoesterreich"
    /// Oberösterreich
     case region_oberoesterreich_key = "region_oberoesterreich"
    /// Salzburg
     case region_salzburg_key = "region_salzburg"
    /// Steiermark
     case region_steiermark_key = "region_steiermark"
    /// Tirol
     case region_tirol_key = "region_tirol"
    /// Eintritt
     case region_type_ET_key = "region_type_ET"
    /// Eintritt
     case region_type_ET_validity_key = "region_type_ET_validity"
    /// Ungültig für
     case region_type_invalid_key = "region_type_invalid"
    /// Nachtgastronomie
     case region_type_NG_key = "region_type_NG"
    /// Nachtgastronomie
     case region_type_NG_validity_key = "region_type_NG_validity"
    /// Gültig für
     case region_type_valid_key = "region_type_valid"
    /// Vorarlberg
     case region_vorarlberg_key = "region_vorarlberg"
    /// Wien
     case region_wien_key = "region_wien"
    /// Covid-19
     case target_disease_name_key = "target_disease_name"
    /// Ein unbekannter Fehler ist aufgetreten.
     case unknown_error_key = "unknown_error"
    /// Erneut erinnern
     case vaccination_booster_notification_later_key = "vaccination_booster_notification_later"
    /// Um weiterhin ein gültiges Zertifikat vorweisen zu können, wird eine Auffrischungsimpfung in den nächsten 3 Monaten empfohlen.
     case vaccination_booster_notification_message_key = "vaccination_booster_notification_message"
    /// Gelesen
     case vaccination_booster_notification_read_key = "vaccination_booster_notification_read"
    /// Achtung Zertifikat läuft ab!
     case vaccination_booster_notification_title_key = "vaccination_booster_notification_title"
    /// Grüner Pass
     case verifier_app_name_key = "verifier_app_name"
    /// Geburtsdatum
     case verifier_covid_certificate_birthdate_key = "verifier_covid_certificate_birthdate"
    /// Nachname
     case verifier_covid_certificate_name_key = "verifier_covid_certificate_name"
    /// Vorname
     case verifier_covid_certificate_prename_key = "verifier_covid_certificate_prename"
    /// Das Format des EU-konformen Zertifikats ist ungültig.
     case verifier_error_invalid_format_key = "verifier_error_invalid_format"
    /// Grüner Pass
     case verifier_homescreen_header_title_key = "verifier_homescreen_header_title"
    /// EU-konformen QR-Code scannen
     case verifier_homescreen_pager_description_1_key = "verifier_homescreen_pager_description_1"
    /// QR-Code scannen
     case verifier_homescreen_scan_button_key = "verifier_homescreen_scan_button"
    /// So funktioniert's
     case verifier_homescreen_support_button_key = "verifier_homescreen_support_button"
    /// Grüner Pass
     case verifier_homescreen_title_key = "verifier_homescreen_title"
    /// Ein unerwarteter Fehler ist aufgetreten
     case verifier_network_error_text_key = "verifier_network_error_text"
    /// Prüfung fehlgeschlagen
     case verifier_network_error_title_key = "verifier_network_error_title"
    /// QR-Code scannen
     case verifier_qr_scanner_scan_qr_text_key = "verifier_qr_scanner_scan_qr_text"
    /// Das Gerät befindet sich im Flugmodus.
     case verifier_retry_flightmode_error_key = "verifier_retry_flightmode_error"
    /// Ein Netzwerkfehler ist aufgetreten.
     case verifier_retry_network_error_key = "verifier_retry_network_error"
    /// https://gruenerpass.gv.at/app/datenschutz
     case verifier_terms_privacy_link_key = "verifier_terms_privacy_link"
    /// QR-Code scannen
     case verifier_title_qr_scan_key = "verifier_title_qr_scan"
    /// Das Zertifikat wurde widerrufen
     case verifier_verify_error_info_for_blacklist_key = "verifier_verify_error_info_for_blacklist"
    /// Das Zertifikat hat keine gültige Signatur
     case verifier_verify_error_info_for_certificate_invalid_key = "verifier_verify_error_info_for_certificate_invalid"
    /// Das Zertifikat entspricht nicht den gesetzlichen Erfordernissen.
     case verifier_verify_error_info_for_national_rules_key = "verifier_verify_error_info_for_national_rules"
    /// Ein unerwarteter Fehler ist aufgetreten.
     case verifier_verify_error_list_info_text_key = "verifier_verify_error_list_info_text"
    /// Prüfung fehlgeschlagen
     case verifier_verify_error_list_title_key = "verifier_verify_error_list_title"
    /// Zertifikat ungültig
     case verifier_verify_error_title_key = "verifier_verify_error_title"
    /// Zertifikat wird geprüft
     case verifier_verify_loading_text_key = "verifier_verify_loading_text"
    /// Nur mit einem amtlichen Lichtbildausweis gültig
     case verifier_verify_success_info_key = "verifier_verify_success_info"
    /// Prüfung erfolgreich
     case verifier_verify_success_title_key = "verifier_verify_success_title"
    /// Nur in Verbindung mit einem amtlichen Lichtbildausweis gültig. Zur Überprüfung verwenden Sie bitte GreenCheck.
     case wallet_3g_status_disclaimer_key = "wallet_3g_status_disclaimer"
    /// Dieses Zertifikat berechtigt für
     case wallet_3g_status_validity_headline_key = "wallet_3g_status_validity_headline"
    /// Hinzufügen
     case wallet_add_certificate_key = "wallet_add_certificate"
    /// Hinzufügen
     case wallet_add_certificate_button_key = "wallet_add_certificate_button"
    /// Grüner Pass
     case wallet_app_name_key = "wallet_app_name"
    /// https://itunes.apple.com/app/id1574155774
     case wallet_apple_app_store_url_key = "wallet_apple_app_store_url"
    /// EU-konformes Zertifikat
     case wallet_certificate_key = "wallet_certificate"
    /// Dieses EU-konforme Zertifikat ist bereits in der App gespeichert
     case wallet_certificate_already_exists_key = "wallet_certificate_already_exists"
    /// Zertifikat erstellt am\n{DATE}
     case wallet_certificate_date_key = "wallet_certificate_date"
    /// Wollen Sie das Zertifikat wirklich löschen?
     case wallet_certificate_delete_confirm_text_key = "wallet_certificate_delete_confirm_text"
    /// Dieses Zertifikat ist kein Reisedokument. \n\nDie wissenschaftlichen Erkenntnisse über Covid-19-Impfungen und -Tests sowie über die Genesung von einer Covid-19-Infektion entwickeln sich ständig weiter, auch im Hinblick auf neue besorgniserregende Virusvarianten. \n\nBitte informieren Sie sich vor der Reise über die am Zielort geltenden Gesundheitsmassnahmen und damit verbundenen Beschränkungen.
     case wallet_certificate_detail_note_key = "wallet_certificate_detail_note"
    /// UVCI
     case wallet_certificate_identifier_key = "wallet_certificate_identifier"
    /// Impfdosis
     case wallet_certificate_impfdosis_title_key = "wallet_certificate_impfdosis_title"
    /// Hersteller
     case wallet_certificate_impfstoff_holder_key = "wallet_certificate_impfstoff_holder"
    /// Produkt
     case wallet_certificate_impfstoff_product_name_title_key = "wallet_certificate_impfstoff_product_name_title"
    /// EU-konforme Zertifikate
     case wallet_certificate_list_title_key = "wallet_certificate_list_title"
    /// Datum des ersten positiven Resultats
     case wallet_certificate_recovery_first_positiv_result_key = "wallet_certificate_recovery_first_positiv_result"
    /// Gültig ab
     case wallet_certificate_recovery_from_key = "wallet_certificate_recovery_from"
    /// Gültig bis
     case wallet_certificate_recovery_until_key = "wallet_certificate_recovery_until"
    /// Krankheit oder Erreger
     case wallet_certificate_target_disease_title_key = "wallet_certificate_target_disease_title"
    /// Testcenter
     case wallet_certificate_test_done_by_key = "wallet_certificate_test_done_by"
    /// Hersteller
     case wallet_certificate_test_holder_key = "wallet_certificate_test_holder"
    /// Land des Tests
     case wallet_certificate_test_land_key = "wallet_certificate_test_land"
    /// Name
     case wallet_certificate_test_name_key = "wallet_certificate_test_name"
    /// Datum Resultat
     case wallet_certificate_test_result_date_title_key = "wallet_certificate_test_result_date_title"
    /// Nicht nachgewiesen
     case wallet_certificate_test_result_negativ_key = "wallet_certificate_test_result_negativ"
    /// Positiv
     case wallet_certificate_test_result_positiv_key = "wallet_certificate_test_result_positiv"
    /// Ergebnis
     case wallet_certificate_test_result_title_key = "wallet_certificate_test_result_title"
    /// Datum der Probenentnahme
     case wallet_certificate_test_sample_date_title_key = "wallet_certificate_test_sample_date_title"
    /// Typ
     case wallet_certificate_test_type_key = "wallet_certificate_test_type"
    /// Land der Impfung
     case wallet_certificate_vaccination_country_title_key = "wallet_certificate_vaccination_country_title"
    /// Impfdatum
     case wallet_certificate_vaccination_date_title_key = "wallet_certificate_vaccination_date_title"
    /// Herausgeber
     case wallet_certificate_vaccination_issuer_title_key = "wallet_certificate_vaccination_issuer_title"
    /// Art des Impfstoffs
     case wallet_certificate_vaccine_prophylaxis_key = "wallet_certificate_vaccine_prophylaxis"
    /// bis
     case wallet_certificate_valid_until_key = "wallet_certificate_valid_until"
    /// %@\n%@
     case wallet_certificate_validity_key = "wallet_certificate_validity"
    /// Prüfung erfolgreich
     case wallet_certificate_verify_success_key = "wallet_certificate_verify_success"
    /// Das Zertifikat wird geprüft
     case wallet_certificate_verifying_key = "wallet_certificate_verifying"
    /// Versuchen Sie es später erneut.
     case wallet_detail_network_error_text_key = "wallet_detail_network_error_text"
    /// Prüfung zurzeit nicht möglich
     case wallet_detail_network_error_title_key = "wallet_detail_network_error_title"
    /// Prüfung offline nicht möglich
     case wallet_detail_offline_retry_title_key = "wallet_detail_offline_retry_title"
    /// Gültigkeit des Zertifikats\nabgelaufen
     case wallet_error_expired_key = "wallet_error_expired"
    /// abgelaufen
     case wallet_error_expired_bold_key = "wallet_error_expired_bold"
    /// Format des Zertifikat\nungültig
     case wallet_error_invalid_format_key = "wallet_error_invalid_format"
    /// ungültig
     case wallet_error_invalid_format_bold_key = "wallet_error_invalid_format_bold"
    /// Zertifikat mit\nungültiger Signatur
     case wallet_error_invalid_signature_key = "wallet_error_invalid_signature"
    /// ungültiger Signatur
     case wallet_error_invalid_signature_bold_key = "wallet_error_invalid_signature_bold"
    /// Das Zertifikat entspricht nicht den gesetzlichen Erfordernissen.
     case wallet_error_national_rules_key = "wallet_error_national_rules"
    /// Zertifikat wurde\nwiderrufen
     case wallet_error_revocation_key = "wallet_error_revocation"
    /// widerrufen
     case wallet_error_revocation_bold_key = "wallet_error_revocation_bold"
    /// In Österreich gültig ab:\n{DATE}
     case wallet_error_valid_from_key = "wallet_error_valid_from"
    /// Häufig gestellte Fragen
     case wallet_faq_header_key = "wallet_faq_header"
    /// Sie haben ein EU-konformes Zertifikat auf Papier oder als PDF und möchten es zur App hinzufügen.
     case wallet_homescreen_add_certificate_description_key = "wallet_homescreen_add_certificate_description"
    /// Zertifikat hinzufügen
     case wallet_homescreen_add_title_key = "wallet_homescreen_add_title"
    /// Scannen Sie den EU-konformen QR-Code auf dem Zertifikat, um es zur App hinzuzufügen.
     case wallet_homescreen_explanation_key = "wallet_homescreen_explanation"
    /// Gültigkeit konnte nicht ermittelt werden
     case wallet_homescreen_network_error_key = "wallet_homescreen_network_error"
    /// Offline Modus
     case wallet_homescreen_offline_key = "wallet_homescreen_offline"
    /// PDF importieren
     case wallet_homescreen_pdf_import_key = "wallet_homescreen_pdf_import"
    /// QR-Code scannen
     case wallet_homescreen_qr_code_scannen_key = "wallet_homescreen_qr_code_scannen"
    /// Nächsten Schritt wählen
     case wallet_homescreen_what_to_do_key = "wallet_homescreen_what_to_do"
    /// Termin
     case wallet_notification_booster_info_button_key = "wallet_notification_booster_info_button"
    /// https://www.oesterreich-impft.at/jetzt-impfen/
     case wallet_notification_booster_info_url_key = "wallet_notification_booster_info_url"
    /// Später
     case wallet_notification_booster_later_button_key = "wallet_notification_booster_later_button"
    /// Holen Sie sich ab 6 Monate nach Ihrer 2. Covid-19 Schutzimpfung Ihre 3. Impfung, um auch gegen die Delta-Variante geschützt zu bleiben!\nIhr Impfzertifikat für den Grünen Pass ist ab 06.12.2021 nur noch 9 Monate ab der 2. Impfung gültig und wird mit der 3. Impfung verlängert.
     case wallet_notification_booster_message_key = "wallet_notification_booster_message"
    /// OK
     case wallet_notification_booster_ok_button_key = "wallet_notification_booster_ok_button"
    /// Achtung!
     case wallet_notification_booster_title_key = "wallet_notification_booster_title"
    /// Termin
     case wallet_notification_johnson_booster_info_button_key = "wallet_notification_johnson_booster_info_button"
    /// https://www.oesterreich-impft.at/jetzt-impfen/
     case wallet_notification_johnson_booster_info_url_key = "wallet_notification_johnson_booster_info_url"
    /// Achtung: Holen Sie sich ab 28 Tagen nach Ihrer Erstimpfung mit dem COVID-19 Vaccine Janssen ("Johnson&Johnson") Ihre 2. Impfung!\n\nIhr Impfzertifikat für den Grünen Pass ist ab Montag, 03.01.2022, nur noch mit 2 Impfungen gültig.
     case wallet_notification_johnson_booster_message_key = "wallet_notification_johnson_booster_message"
    /// OK
     case wallet_notification_johnson_booster_ok_button_key = "wallet_notification_johnson_booster_ok_button"
    /// Weiter
     case wallet_notification_permission_button_key = "wallet_notification_permission_button"
    /// Die App kann Sie informieren, sobald das Zertifikat eingetroffen ist.  Erlauben Sie dazu der App, Ihnen Mitteilungen zu senden.
     case wallet_notification_permission_text_key = "wallet_notification_permission_text"
    /// Mitteilungen erlauben
     case wallet_notification_permission_title_key = "wallet_notification_permission_title"
    /// Um die aktuelle Gültigkeit anzeigen zu können, muss die App regelmässig online sein.
     case wallet_offline_description_key = "wallet_offline_description"
    /// Akzeptieren
     case wallet_onboarding_accept_button_key = "wallet_onboarding_accept_button"
    /// Grüner Pass
     case wallet_onboarding_app_header_key = "wallet_onboarding_app_header"
    /// Mit dieser App können Sie die EU-konformen Zertifikate des Grünen Passes sicher auf dem Smartphone aufbewahren und einfach vorweisen.
     case wallet_onboarding_app_text_key = "wallet_onboarding_app_text"
    /// Grüner Pass
     case wallet_onboarding_app_title_key = "wallet_onboarding_app_title"
    /// Datenschutzerklärung &\nNutzungsbedingungen
     case wallet_onboarding_external_privacy_button_key = "wallet_onboarding_external_privacy_button"
    /// Nutzungsbedingungen
     case wallet_onboarding_privacy_conditionsofuse_title_key = "wallet_onboarding_privacy_conditionsofuse_title"
    /// Datenschutz
     case wallet_onboarding_privacy_header_key = "wallet_onboarding_privacy_header"
    /// Grünes Schild mit Häkchen
     case wallet_onboarding_privacy_icon1_key = "wallet_onboarding_privacy_icon1"
    /// Datenschutzerklärung
     case wallet_onboarding_privacy_privacypolicy_title_key = "wallet_onboarding_privacy_privacypolicy_title"
    /// Die Zertifikate sind nur lokal auf Ihrem Smartphone hinterlegt. Die Daten werden nicht in einem zentralen System gespeichert.
     case wallet_onboarding_privacy_text_key = "wallet_onboarding_privacy_text"
    /// Ihre Daten bleiben \nin der App
     case wallet_onboarding_privacy_title_key = "wallet_onboarding_privacy_title"
    /// Vorteile
     case wallet_onboarding_show_header_key = "wallet_onboarding_show_header"
    /// QR Code
     case wallet_onboarding_show_icon1_key = "wallet_onboarding_show_icon1"
    /// Grünes Häkchen
     case wallet_onboarding_show_icon2_key = "wallet_onboarding_show_icon2"
    /// Die auf dem Zertifikat dargestellten Daten sind auch im EU-konformen QR-Code enthalten.
     case wallet_onboarding_show_text1_key = "wallet_onboarding_show_text1"
    /// Beim Vorweisen wird der EU-konforme QR-Code mit einer Prüfanwendung gescannt. Die enthaltenen Daten werden dabei automatisch auf Echtheit und Gültigkeit überprüft.
     case wallet_onboarding_show_text2_key = "wallet_onboarding_show_text2"
    /// Zertifikate einfach vorweisen
     case wallet_onboarding_show_title_key = "wallet_onboarding_show_title"
    /// Vorteile
     case wallet_onboarding_store_header_key = "wallet_onboarding_store_header"
    /// Schloss
     case wallet_onboarding_store_icon1_key = "wallet_onboarding_store_icon1"
    /// Die EU-konformen Zertifikate des Grünen Passes können einfach zur App hinzugefügt und digital aufbewahrt werden.
     case wallet_onboarding_store_text1_key = "wallet_onboarding_store_text1"
    /// EU-konforme Zertifikate digital aufbewahren
     case wallet_onboarding_store_title_key = "wallet_onboarding_store_title"
    /// Je nach Bundesland können andere Zutrittsregeln gelten. Sie können das Bundesland jederzeit ändern.
     case wallet_region_selection_header_message_key = "wallet_region_selection_header_message"
    /// Bundesland wählen
     case wallet_region_selection_header_title_key = "wallet_region_selection_header_title"
    /// Bundeslandauswahl
     case wallet_region_selection_title_key = "wallet_region_selection_title"
    /// Erneut scannen
     case wallet_scan_again_key = "wallet_scan_again"
    /// Scannen Sie den EU-konformen QR-Code auf dem Zertifikat.
     case wallet_scanner_explanation_key = "wallet_scanner_explanation"
    /// Alle EU-konformen Zertifikate des Grünen Passes können mittels Handy-Signatur oder Bürgerkarte über gesundheit.gv.at abgerufen werden.
     case wallet_scanner_howitworks_answer1_key = "wallet_scanner_howitworks_answer1"
    /// https://gruenerpass.gv.at/
     case wallet_scanner_howitworks_external_link_key = "wallet_scanner_howitworks_external_link"
    /// Weitere Informationen
     case wallet_scanner_howitworks_external_link_title_key = "wallet_scanner_howitworks_external_link_title"
    /// So funktioniert's
     case wallet_scanner_howitworks_header_key = "wallet_scanner_howitworks_header"
    /// Erster Schritt
     case wallet_scanner_howitworks_icon1_key = "wallet_scanner_howitworks_icon1"
    /// Zweiter Schritt
     case wallet_scanner_howitworks_icon2_key = "wallet_scanner_howitworks_icon2"
    /// Dritter Schritt
     case wallet_scanner_howitworks_icon3_key = "wallet_scanner_howitworks_icon3"
    /// Wie und wo erhalte ich ein EU-konformes Zertifikat?
     case wallet_scanner_howitworks_question1_key = "wallet_scanner_howitworks_question1"
    /// Um ein Zertifikat zur App hinzufügen zu können, benötigen Sie das Originalzertifikat auf Papier oder als PDF.
     case wallet_scanner_howitworks_text1_key = "wallet_scanner_howitworks_text1"
    /// Tippen Sie in der App auf «Hinzufügen», um ein neues Zertifikat zur App hinzuzufügen.
     case wallet_scanner_howitworks_text2_key = "wallet_scanner_howitworks_text2"
    /// Halten Sie nun die Kamera des Smartphones über den EU-konformen QR-Code auf dem Zertifikat, um diesen zu scannen.
     case wallet_scanner_howitworks_text3_key = "wallet_scanner_howitworks_text3"
    /// Es erscheint eine Vorschau des Zertifikats. Tippen Sie auf «Hinzufügen» um das Zertifikat sicher in der App zu speichern.
     case wallet_scanner_howitworks_text4_key = "wallet_scanner_howitworks_text4"
    /// Zertifikate\nhinzufügen
     case wallet_scanner_howitworks_title_key = "wallet_scanner_howitworks_title"
    /// So funktioniert's
     case wallet_scanner_info_button_key = "wallet_scanner_info_button"
    /// Hinzufügen
     case wallet_scanner_title_key = "wallet_scanner_title"
    /// https://gruenerpass.gv.at/app/datenschutz
     case wallet_terms_privacy_link_key = "wallet_terms_privacy_link"
    /// 3-G Status nicht verfügbar, bitte aktivieren Sie die Internetverbindung
     case wallet_time_missing_key = "wallet_time_missing"
    /// 3-G Status nicht verfügbar, bitte aktivieren Sie die Internetverbindung
     case wallet_validation_data_expired_key = "wallet_validation_data_expired"
    /// Bildschirmaufnahme ist nicht erlaubt!
     case warning_screen_recording_key = "warning_screen_recording"
  }

  /// Kamera ist Aktiv
   static let accessibility_active_camera = UBLocalized.tr(UBLocalizedKey.accessibility_active_camera_key)
  /// Zertifikat hinzufügen
   static let accessibility_add_button = UBLocalized.tr(UBLocalizedKey.accessibility_add_button_key)
  /// Ungültig
   static let accessibility_certificate_list_in_valid = UBLocalized.tr(UBLocalizedKey.accessibility_certificate_list_in_valid_key)
  /// Gültig
   static let accessibility_certificate_list_valid = UBLocalized.tr(UBLocalizedKey.accessibility_certificate_list_valid_key)
  /// Zum Ändern Doppeltippen
   static let accessibility_change_selected_region = UBLocalized.tr(UBLocalizedKey.accessibility_change_selected_region_key)
  /// Schliessen
   static let accessibility_close_button = UBLocalized.tr(UBLocalizedKey.accessibility_close_button_key)
  /// Für die Detailansicht Doppeltippen
   static let accessibility_detail_certificate = UBLocalized.tr(UBLocalizedKey.accessibility_detail_certificate_key)
  /// Öffnet in neuem Fenster
   static let accessibility_external_link = UBLocalized.tr(UBLocalizedKey.accessibility_external_link_key)
  /// Häufige Fragen
   static let accessibility_faq_button = UBLocalized.tr(UBLocalizedKey.accessibility_faq_button_key)
  /// Kamera ist nicht mehr Aktiv
   static let accessibility_in_active_camera = UBLocalized.tr(UBLocalizedKey.accessibility_in_active_camera_key)
  /// Information
   static let accessibility_info_box = UBLocalized.tr(UBLocalizedKey.accessibility_info_box_key)
  /// Impressum
   static let accessibility_info_button = UBLocalized.tr(UBLocalizedKey.accessibility_info_button_key)
  /// Taschenlampe ausschalten
   static let accessibility_lamp_off_button = UBLocalized.tr(UBLocalizedKey.accessibility_lamp_off_button_key)
  /// Taschenlampe einschalten
   static let accessibility_lamp_on_button = UBLocalized.tr(UBLocalizedKey.accessibility_lamp_on_button_key)
  /// Liste Ihrer Zertifikate
   static let accessibility_list_button = UBLocalized.tr(UBLocalizedKey.accessibility_list_button_key)
  /// von
   static let accessibility_of_text = UBLocalized.tr(UBLocalizedKey.accessibility_of_text_key)
  /// Seite
   static let accessibility_page_control_page = UBLocalized.tr(UBLocalizedKey.accessibility_page_control_page_key)
  /// Aktiv
   static let accessibility_region_active = UBLocalized.tr(UBLocalizedKey.accessibility_region_active_key)
  /// Zum Ändern Doppeltippen
   static let accessibility_region_in_active = UBLocalized.tr(UBLocalizedKey.accessibility_region_in_active_key)
  /// Aktuelle Region
   static let accessibility_selected_region = UBLocalized.tr(UBLocalizedKey.accessibility_selected_region_key)
  /// Zugriff auf Kamera erlauben
   static let camera_permission_dialog_action = UBLocalized.tr(UBLocalizedKey.camera_permission_dialog_action_key)
  /// Die App benötigt Zugriff auf die Kamera, um den QR-Code scannen zu können.
   static let camera_permission_dialog_text = UBLocalized.tr(UBLocalizedKey.camera_permission_dialog_text_key)
  /// Abbrechen
   static let cancel_button = UBLocalized.tr(UBLocalizedKey.cancel_button_key)
  /// QR Code, Bild
   static let certificate_details_qr_icon = UBLocalized.tr(UBLocalizedKey.certificate_details_qr_icon_key)
  /// Genesung
   static let certificate_reason_recovered = UBLocalized.tr(UBLocalizedKey.certificate_reason_recovered_key)
  /// Test
   static let certificate_reason_tested = UBLocalized.tr(UBLocalizedKey.certificate_reason_tested_key)
  /// Impfung
   static let certificate_reason_vaccinated = UBLocalized.tr(UBLocalizedKey.certificate_reason_vaccinated_key)
  /// Schliessen
   static let close_button = UBLocalized.tr(UBLocalizedKey.close_button_key)
  /// Weiter
   static let continue_button = UBLocalized.tr(UBLocalizedKey.continue_button_key)
  /// Genesung
   static let covid_certificate_recovery_title = UBLocalized.tr(UBLocalizedKey.covid_certificate_recovery_title_key)
  /// Test
   static let covid_certificate_test_title = UBLocalized.tr(UBLocalizedKey.covid_certificate_test_title_key)
  /// EU-konformes Zertifikat
   static let covid_certificate_title = UBLocalized.tr(UBLocalizedKey.covid_certificate_title_key)
  /// Impfung
   static let covid_certificate_vaccination_title = UBLocalized.tr(UBLocalizedKey.covid_certificate_vaccination_title_key)
  /// Löschen
   static let delete_button = UBLocalized.tr(UBLocalizedKey.delete_button_key)
  /// Einstellungen ändern
   static let error_action_change_settings = UBLocalized.tr(UBLocalizedKey.error_action_change_settings_key)
  /// Erneut versuchen
   static let error_action_retry = UBLocalized.tr(UBLocalizedKey.error_action_retry_key)
  /// Die App benötigt Zugriff auf die Kamera, um das Zertifikat scannen zu können.
   static let error_camera_permission_text = UBLocalized.tr(UBLocalizedKey.error_camera_permission_text_key)
  /// Kein Zugriff auf Kamera
   static let error_camera_permission_title = UBLocalized.tr(UBLocalizedKey.error_camera_permission_title_key)
  /// Überprüfen Sie Ihre Internet Verbindung.
   static let error_network_text = UBLocalized.tr(UBLocalizedKey.error_network_text_key)
  /// Netzwerkfehler
   static let error_network_title = UBLocalized.tr(UBLocalizedKey.error_network_title_key)
  /// Fehler
   static let error_title = UBLocalized.tr(UBLocalizedKey.error_title_key)
  /// Aktualisieren
   static let force_update_button = UBLocalized.tr(UBLocalizedKey.force_update_button_key)
  /// Jetzt nicht
   static let force_update_grace_period_skip_button = UBLocalized.tr(UBLocalizedKey.force_update_grace_period_skip_button_key)
  /// Bitte laden Sie vor %@ die neueste Version der App.
   static func force_update_grace_period_text(_ p1: Any) -> String {
    return UBLocalized.tr(UBLocalizedKey.force_update_grace_period_text_key, String(describing: p1))
  }
  /// Update benötigt
   static let force_update_grace_period_title = UBLocalized.tr(UBLocalizedKey.force_update_grace_period_title_key)
  /// Aktualisieren
   static let force_update_grace_period_update_button = UBLocalized.tr(UBLocalizedKey.force_update_grace_period_update_button_key)
  /// Laden Sie die neue Version der App.
   static let force_update_text = UBLocalized.tr(UBLocalizedKey.force_update_text_key)
  /// Update benötigt
   static let force_update_title = UBLocalized.tr(UBLocalizedKey.force_update_title_key)
  /// Impressum
   static let impressum_title = UBLocalized.tr(UBLocalizedKey.impressum_title_key)
  /// Einstellungen
   static let ios_settings_open = UBLocalized.tr(UBLocalizedKey.ios_settings_open_key)
  /// de
   static let language_key = UBLocalized.tr(UBLocalizedKey.language_key_key)
  /// Die App benötigt Zugriff auf die Kamera, um den EU-konformen QR-Code scannen zu können.
   static let NSCameraUsageDescription = UBLocalized.tr(UBLocalizedKey.NSCameraUsageDescription_key)
  /// OK
   static let ok_button = UBLocalized.tr(UBLocalizedKey.ok_button_key)
  /// Kein gültiger Code
   static let qr_scanner_error = UBLocalized.tr(UBLocalizedKey.qr_scanner_error_key)
  /// Burgenland
   static let region_burgenland = UBLocalized.tr(UBLocalizedKey.region_burgenland_key)
  /// Kärnten
   static let region_kaernten = UBLocalized.tr(UBLocalizedKey.region_kaernten_key)
  /// Bundesweit
   static let region_nationwide = UBLocalized.tr(UBLocalizedKey.region_nationwide_key)
  /// Bundesweit\n(exkl. Wien)
   static let region_nationwide_validity = UBLocalized.tr(UBLocalizedKey.region_nationwide_validity_key)
  /// Niederösterreich
   static let region_niederoesterreich = UBLocalized.tr(UBLocalizedKey.region_niederoesterreich_key)
  /// Oberösterreich
   static let region_oberoesterreich = UBLocalized.tr(UBLocalizedKey.region_oberoesterreich_key)
  /// Salzburg
   static let region_salzburg = UBLocalized.tr(UBLocalizedKey.region_salzburg_key)
  /// Steiermark
   static let region_steiermark = UBLocalized.tr(UBLocalizedKey.region_steiermark_key)
  /// Tirol
   static let region_tirol = UBLocalized.tr(UBLocalizedKey.region_tirol_key)
  /// Eintritt
   static let region_type_ET = UBLocalized.tr(UBLocalizedKey.region_type_ET_key)
  /// Eintritt
   static let region_type_ET_validity = UBLocalized.tr(UBLocalizedKey.region_type_ET_validity_key)
  /// Ungültig für
   static let region_type_invalid = UBLocalized.tr(UBLocalizedKey.region_type_invalid_key)
  /// Nachtgastronomie
   static let region_type_NG = UBLocalized.tr(UBLocalizedKey.region_type_NG_key)
  /// Nachtgastronomie
   static let region_type_NG_validity = UBLocalized.tr(UBLocalizedKey.region_type_NG_validity_key)
  /// Gültig für
   static let region_type_valid = UBLocalized.tr(UBLocalizedKey.region_type_valid_key)
  /// Vorarlberg
   static let region_vorarlberg = UBLocalized.tr(UBLocalizedKey.region_vorarlberg_key)
  /// Wien
   static let region_wien = UBLocalized.tr(UBLocalizedKey.region_wien_key)
  /// Covid-19
   static let target_disease_name = UBLocalized.tr(UBLocalizedKey.target_disease_name_key)
  /// Ein unbekannter Fehler ist aufgetreten.
   static let unknown_error = UBLocalized.tr(UBLocalizedKey.unknown_error_key)
  /// Erneut erinnern
   static let vaccination_booster_notification_later = UBLocalized.tr(UBLocalizedKey.vaccination_booster_notification_later_key)
  /// Um weiterhin ein gültiges Zertifikat vorweisen zu können, wird eine Auffrischungsimpfung in den nächsten 3 Monaten empfohlen.
   static let vaccination_booster_notification_message = UBLocalized.tr(UBLocalizedKey.vaccination_booster_notification_message_key)
  /// Gelesen
   static let vaccination_booster_notification_read = UBLocalized.tr(UBLocalizedKey.vaccination_booster_notification_read_key)
  /// Achtung Zertifikat läuft ab!
   static let vaccination_booster_notification_title = UBLocalized.tr(UBLocalizedKey.vaccination_booster_notification_title_key)
  /// Grüner Pass
   static let verifier_app_name = UBLocalized.tr(UBLocalizedKey.verifier_app_name_key)
  /// Geburtsdatum
   static let verifier_covid_certificate_birthdate = UBLocalized.tr(UBLocalizedKey.verifier_covid_certificate_birthdate_key)
  /// Nachname
   static let verifier_covid_certificate_name = UBLocalized.tr(UBLocalizedKey.verifier_covid_certificate_name_key)
  /// Vorname
   static let verifier_covid_certificate_prename = UBLocalized.tr(UBLocalizedKey.verifier_covid_certificate_prename_key)
  /// Das Format des EU-konformen Zertifikats ist ungültig.
   static let verifier_error_invalid_format = UBLocalized.tr(UBLocalizedKey.verifier_error_invalid_format_key)
  /// Grüner Pass
   static let verifier_homescreen_header_title = UBLocalized.tr(UBLocalizedKey.verifier_homescreen_header_title_key)
  /// EU-konformen QR-Code scannen
   static let verifier_homescreen_pager_description_1 = UBLocalized.tr(UBLocalizedKey.verifier_homescreen_pager_description_1_key)
  /// QR-Code scannen
   static let verifier_homescreen_scan_button = UBLocalized.tr(UBLocalizedKey.verifier_homescreen_scan_button_key)
  /// So funktioniert's
   static let verifier_homescreen_support_button = UBLocalized.tr(UBLocalizedKey.verifier_homescreen_support_button_key)
  /// Grüner Pass
   static let verifier_homescreen_title = UBLocalized.tr(UBLocalizedKey.verifier_homescreen_title_key)
  /// Ein unerwarteter Fehler ist aufgetreten
   static let verifier_network_error_text = UBLocalized.tr(UBLocalizedKey.verifier_network_error_text_key)
  /// Prüfung fehlgeschlagen
   static let verifier_network_error_title = UBLocalized.tr(UBLocalizedKey.verifier_network_error_title_key)
  /// QR-Code scannen
   static let verifier_qr_scanner_scan_qr_text = UBLocalized.tr(UBLocalizedKey.verifier_qr_scanner_scan_qr_text_key)
  /// Das Gerät befindet sich im Flugmodus.
   static let verifier_retry_flightmode_error = UBLocalized.tr(UBLocalizedKey.verifier_retry_flightmode_error_key)
  /// Ein Netzwerkfehler ist aufgetreten.
   static let verifier_retry_network_error = UBLocalized.tr(UBLocalizedKey.verifier_retry_network_error_key)
  /// https://gruenerpass.gv.at/app/datenschutz
   static let verifier_terms_privacy_link = UBLocalized.tr(UBLocalizedKey.verifier_terms_privacy_link_key)
  /// QR-Code scannen
   static let verifier_title_qr_scan = UBLocalized.tr(UBLocalizedKey.verifier_title_qr_scan_key)
  /// Das Zertifikat wurde widerrufen
   static let verifier_verify_error_info_for_blacklist = UBLocalized.tr(UBLocalizedKey.verifier_verify_error_info_for_blacklist_key)
  /// Das Zertifikat hat keine gültige Signatur
   static let verifier_verify_error_info_for_certificate_invalid = UBLocalized.tr(UBLocalizedKey.verifier_verify_error_info_for_certificate_invalid_key)
  /// Das Zertifikat entspricht nicht den gesetzlichen Erfordernissen.
   static let verifier_verify_error_info_for_national_rules = UBLocalized.tr(UBLocalizedKey.verifier_verify_error_info_for_national_rules_key)
  /// Ein unerwarteter Fehler ist aufgetreten.
   static let verifier_verify_error_list_info_text = UBLocalized.tr(UBLocalizedKey.verifier_verify_error_list_info_text_key)
  /// Prüfung fehlgeschlagen
   static let verifier_verify_error_list_title = UBLocalized.tr(UBLocalizedKey.verifier_verify_error_list_title_key)
  /// Zertifikat ungültig
   static let verifier_verify_error_title = UBLocalized.tr(UBLocalizedKey.verifier_verify_error_title_key)
  /// Zertifikat wird geprüft
   static let verifier_verify_loading_text = UBLocalized.tr(UBLocalizedKey.verifier_verify_loading_text_key)
  /// Nur mit einem amtlichen Lichtbildausweis gültig
   static let verifier_verify_success_info = UBLocalized.tr(UBLocalizedKey.verifier_verify_success_info_key)
  /// Prüfung erfolgreich
   static let verifier_verify_success_title = UBLocalized.tr(UBLocalizedKey.verifier_verify_success_title_key)
  /// Nur in Verbindung mit einem amtlichen Lichtbildausweis gültig. Zur Überprüfung verwenden Sie bitte GreenCheck.
   static let wallet_3g_status_disclaimer = UBLocalized.tr(UBLocalizedKey.wallet_3g_status_disclaimer_key)
  /// Dieses Zertifikat berechtigt für
   static let wallet_3g_status_validity_headline = UBLocalized.tr(UBLocalizedKey.wallet_3g_status_validity_headline_key)
  /// Hinzufügen
   static let wallet_add_certificate = UBLocalized.tr(UBLocalizedKey.wallet_add_certificate_key)
  /// Hinzufügen
   static let wallet_add_certificate_button = UBLocalized.tr(UBLocalizedKey.wallet_add_certificate_button_key)
  /// Grüner Pass
   static let wallet_app_name = UBLocalized.tr(UBLocalizedKey.wallet_app_name_key)
  /// https://itunes.apple.com/app/id1574155774
   static let wallet_apple_app_store_url = UBLocalized.tr(UBLocalizedKey.wallet_apple_app_store_url_key)
  /// EU-konformes Zertifikat
   static let wallet_certificate = UBLocalized.tr(UBLocalizedKey.wallet_certificate_key)
  /// Dieses EU-konforme Zertifikat ist bereits in der App gespeichert
   static let wallet_certificate_already_exists = UBLocalized.tr(UBLocalizedKey.wallet_certificate_already_exists_key)
  /// Zertifikat erstellt am\n{DATE}
   static let wallet_certificate_date = UBLocalized.tr(UBLocalizedKey.wallet_certificate_date_key)
  /// Wollen Sie das Zertifikat wirklich löschen?
   static let wallet_certificate_delete_confirm_text = UBLocalized.tr(UBLocalizedKey.wallet_certificate_delete_confirm_text_key)
  /// Dieses Zertifikat ist kein Reisedokument. \n\nDie wissenschaftlichen Erkenntnisse über Covid-19-Impfungen und -Tests sowie über die Genesung von einer Covid-19-Infektion entwickeln sich ständig weiter, auch im Hinblick auf neue besorgniserregende Virusvarianten. \n\nBitte informieren Sie sich vor der Reise über die am Zielort geltenden Gesundheitsmassnahmen und damit verbundenen Beschränkungen.
   static let wallet_certificate_detail_note = UBLocalized.tr(UBLocalizedKey.wallet_certificate_detail_note_key)
  /// UVCI
   static let wallet_certificate_identifier = UBLocalized.tr(UBLocalizedKey.wallet_certificate_identifier_key)
  /// Impfdosis
   static let wallet_certificate_impfdosis_title = UBLocalized.tr(UBLocalizedKey.wallet_certificate_impfdosis_title_key)
  /// Hersteller
   static let wallet_certificate_impfstoff_holder = UBLocalized.tr(UBLocalizedKey.wallet_certificate_impfstoff_holder_key)
  /// Produkt
   static let wallet_certificate_impfstoff_product_name_title = UBLocalized.tr(UBLocalizedKey.wallet_certificate_impfstoff_product_name_title_key)
  /// EU-konforme Zertifikate
   static let wallet_certificate_list_title = UBLocalized.tr(UBLocalizedKey.wallet_certificate_list_title_key)
  /// Datum des ersten positiven Resultats
   static let wallet_certificate_recovery_first_positiv_result = UBLocalized.tr(UBLocalizedKey.wallet_certificate_recovery_first_positiv_result_key)
  /// Gültig ab
   static let wallet_certificate_recovery_from = UBLocalized.tr(UBLocalizedKey.wallet_certificate_recovery_from_key)
  /// Gültig bis
   static let wallet_certificate_recovery_until = UBLocalized.tr(UBLocalizedKey.wallet_certificate_recovery_until_key)
  /// Krankheit oder Erreger
   static let wallet_certificate_target_disease_title = UBLocalized.tr(UBLocalizedKey.wallet_certificate_target_disease_title_key)
  /// Testcenter
   static let wallet_certificate_test_done_by = UBLocalized.tr(UBLocalizedKey.wallet_certificate_test_done_by_key)
  /// Hersteller
   static let wallet_certificate_test_holder = UBLocalized.tr(UBLocalizedKey.wallet_certificate_test_holder_key)
  /// Land des Tests
   static let wallet_certificate_test_land = UBLocalized.tr(UBLocalizedKey.wallet_certificate_test_land_key)
  /// Name
   static let wallet_certificate_test_name = UBLocalized.tr(UBLocalizedKey.wallet_certificate_test_name_key)
  /// Datum Resultat
   static let wallet_certificate_test_result_date_title = UBLocalized.tr(UBLocalizedKey.wallet_certificate_test_result_date_title_key)
  /// Nicht nachgewiesen
   static let wallet_certificate_test_result_negativ = UBLocalized.tr(UBLocalizedKey.wallet_certificate_test_result_negativ_key)
  /// Positiv
   static let wallet_certificate_test_result_positiv = UBLocalized.tr(UBLocalizedKey.wallet_certificate_test_result_positiv_key)
  /// Ergebnis
   static let wallet_certificate_test_result_title = UBLocalized.tr(UBLocalizedKey.wallet_certificate_test_result_title_key)
  /// Datum der Probenentnahme
   static let wallet_certificate_test_sample_date_title = UBLocalized.tr(UBLocalizedKey.wallet_certificate_test_sample_date_title_key)
  /// Typ
   static let wallet_certificate_test_type = UBLocalized.tr(UBLocalizedKey.wallet_certificate_test_type_key)
  /// Land der Impfung
   static let wallet_certificate_vaccination_country_title = UBLocalized.tr(UBLocalizedKey.wallet_certificate_vaccination_country_title_key)
  /// Impfdatum
   static let wallet_certificate_vaccination_date_title = UBLocalized.tr(UBLocalizedKey.wallet_certificate_vaccination_date_title_key)
  /// Herausgeber
   static let wallet_certificate_vaccination_issuer_title = UBLocalized.tr(UBLocalizedKey.wallet_certificate_vaccination_issuer_title_key)
  /// Art des Impfstoffs
   static let wallet_certificate_vaccine_prophylaxis = UBLocalized.tr(UBLocalizedKey.wallet_certificate_vaccine_prophylaxis_key)
  /// bis
   static let wallet_certificate_valid_until = UBLocalized.tr(UBLocalizedKey.wallet_certificate_valid_until_key)
  /// %@\n%@
   static func wallet_certificate_validity(_ p1: Any, _ p2: Any) -> String {
    return UBLocalized.tr(UBLocalizedKey.wallet_certificate_validity_key, String(describing: p1), String(describing: p2))
  }
  /// Prüfung erfolgreich
   static let wallet_certificate_verify_success = UBLocalized.tr(UBLocalizedKey.wallet_certificate_verify_success_key)
  /// Das Zertifikat wird geprüft
   static let wallet_certificate_verifying = UBLocalized.tr(UBLocalizedKey.wallet_certificate_verifying_key)
  /// Versuchen Sie es später erneut.
   static let wallet_detail_network_error_text = UBLocalized.tr(UBLocalizedKey.wallet_detail_network_error_text_key)
  /// Prüfung zurzeit nicht möglich
   static let wallet_detail_network_error_title = UBLocalized.tr(UBLocalizedKey.wallet_detail_network_error_title_key)
  /// Prüfung offline nicht möglich
   static let wallet_detail_offline_retry_title = UBLocalized.tr(UBLocalizedKey.wallet_detail_offline_retry_title_key)
  /// Gültigkeit des Zertifikats\nabgelaufen
   static let wallet_error_expired = UBLocalized.tr(UBLocalizedKey.wallet_error_expired_key)
  /// abgelaufen
   static let wallet_error_expired_bold = UBLocalized.tr(UBLocalizedKey.wallet_error_expired_bold_key)
  /// Format des Zertifikat\nungültig
   static let wallet_error_invalid_format = UBLocalized.tr(UBLocalizedKey.wallet_error_invalid_format_key)
  /// ungültig
   static let wallet_error_invalid_format_bold = UBLocalized.tr(UBLocalizedKey.wallet_error_invalid_format_bold_key)
  /// Zertifikat mit\nungültiger Signatur
   static let wallet_error_invalid_signature = UBLocalized.tr(UBLocalizedKey.wallet_error_invalid_signature_key)
  /// ungültiger Signatur
   static let wallet_error_invalid_signature_bold = UBLocalized.tr(UBLocalizedKey.wallet_error_invalid_signature_bold_key)
  /// Das Zertifikat entspricht nicht den gesetzlichen Erfordernissen.
   static let wallet_error_national_rules = UBLocalized.tr(UBLocalizedKey.wallet_error_national_rules_key)
  /// Zertifikat wurde\nwiderrufen
   static let wallet_error_revocation = UBLocalized.tr(UBLocalizedKey.wallet_error_revocation_key)
  /// widerrufen
   static let wallet_error_revocation_bold = UBLocalized.tr(UBLocalizedKey.wallet_error_revocation_bold_key)
  /// In Österreich gültig ab:\n{DATE}
   static let wallet_error_valid_from = UBLocalized.tr(UBLocalizedKey.wallet_error_valid_from_key)
  /// Häufig gestellte Fragen
   static let wallet_faq_header = UBLocalized.tr(UBLocalizedKey.wallet_faq_header_key)
  /// Sie haben ein EU-konformes Zertifikat auf Papier oder als PDF und möchten es zur App hinzufügen.
   static let wallet_homescreen_add_certificate_description = UBLocalized.tr(UBLocalizedKey.wallet_homescreen_add_certificate_description_key)
  /// Zertifikat hinzufügen
   static let wallet_homescreen_add_title = UBLocalized.tr(UBLocalizedKey.wallet_homescreen_add_title_key)
  /// Scannen Sie den EU-konformen QR-Code auf dem Zertifikat, um es zur App hinzuzufügen.
   static let wallet_homescreen_explanation = UBLocalized.tr(UBLocalizedKey.wallet_homescreen_explanation_key)
  /// Gültigkeit konnte nicht ermittelt werden
   static let wallet_homescreen_network_error = UBLocalized.tr(UBLocalizedKey.wallet_homescreen_network_error_key)
  /// Offline Modus
   static let wallet_homescreen_offline = UBLocalized.tr(UBLocalizedKey.wallet_homescreen_offline_key)
  /// PDF importieren
   static let wallet_homescreen_pdf_import = UBLocalized.tr(UBLocalizedKey.wallet_homescreen_pdf_import_key)
  /// QR-Code scannen
   static let wallet_homescreen_qr_code_scannen = UBLocalized.tr(UBLocalizedKey.wallet_homescreen_qr_code_scannen_key)
  /// Nächsten Schritt wählen
   static let wallet_homescreen_what_to_do = UBLocalized.tr(UBLocalizedKey.wallet_homescreen_what_to_do_key)
  /// Termin
   static let wallet_notification_booster_info_button = UBLocalized.tr(UBLocalizedKey.wallet_notification_booster_info_button_key)
  /// https://www.oesterreich-impft.at/jetzt-impfen/
   static let wallet_notification_booster_info_url = UBLocalized.tr(UBLocalizedKey.wallet_notification_booster_info_url_key)
  /// Später
   static let wallet_notification_booster_later_button = UBLocalized.tr(UBLocalizedKey.wallet_notification_booster_later_button_key)
  /// Holen Sie sich ab 6 Monate nach Ihrer 2. Covid-19 Schutzimpfung Ihre 3. Impfung, um auch gegen die Delta-Variante geschützt zu bleiben!\nIhr Impfzertifikat für den Grünen Pass ist ab 06.12.2021 nur noch 9 Monate ab der 2. Impfung gültig und wird mit der 3. Impfung verlängert.
   static let wallet_notification_booster_message = UBLocalized.tr(UBLocalizedKey.wallet_notification_booster_message_key)
  /// OK
   static let wallet_notification_booster_ok_button = UBLocalized.tr(UBLocalizedKey.wallet_notification_booster_ok_button_key)
  /// Achtung!
   static let wallet_notification_booster_title = UBLocalized.tr(UBLocalizedKey.wallet_notification_booster_title_key)
  /// Termin
   static let wallet_notification_johnson_booster_info_button = UBLocalized.tr(UBLocalizedKey.wallet_notification_johnson_booster_info_button_key)
  /// https://www.oesterreich-impft.at/jetzt-impfen/
   static let wallet_notification_johnson_booster_info_url = UBLocalized.tr(UBLocalizedKey.wallet_notification_johnson_booster_info_url_key)
  /// Achtung: Holen Sie sich ab 28 Tagen nach Ihrer Erstimpfung mit dem COVID-19 Vaccine Janssen ("Johnson&Johnson") Ihre 2. Impfung!\n\nIhr Impfzertifikat für den Grünen Pass ist ab Montag, 03.01.2022, nur noch mit 2 Impfungen gültig.
   static let wallet_notification_johnson_booster_message = UBLocalized.tr(UBLocalizedKey.wallet_notification_johnson_booster_message_key)
  /// OK
   static let wallet_notification_johnson_booster_ok_button = UBLocalized.tr(UBLocalizedKey.wallet_notification_johnson_booster_ok_button_key)
  /// Weiter
   static let wallet_notification_permission_button = UBLocalized.tr(UBLocalizedKey.wallet_notification_permission_button_key)
  /// Die App kann Sie informieren, sobald das Zertifikat eingetroffen ist.  Erlauben Sie dazu der App, Ihnen Mitteilungen zu senden.
   static let wallet_notification_permission_text = UBLocalized.tr(UBLocalizedKey.wallet_notification_permission_text_key)
  /// Mitteilungen erlauben
   static let wallet_notification_permission_title = UBLocalized.tr(UBLocalizedKey.wallet_notification_permission_title_key)
  /// Um die aktuelle Gültigkeit anzeigen zu können, muss die App regelmässig online sein.
   static let wallet_offline_description = UBLocalized.tr(UBLocalizedKey.wallet_offline_description_key)
  /// Akzeptieren
   static let wallet_onboarding_accept_button = UBLocalized.tr(UBLocalizedKey.wallet_onboarding_accept_button_key)
  /// Grüner Pass
   static let wallet_onboarding_app_header = UBLocalized.tr(UBLocalizedKey.wallet_onboarding_app_header_key)
  /// Mit dieser App können Sie die EU-konformen Zertifikate des Grünen Passes sicher auf dem Smartphone aufbewahren und einfach vorweisen.
   static let wallet_onboarding_app_text = UBLocalized.tr(UBLocalizedKey.wallet_onboarding_app_text_key)
  /// Grüner Pass
   static let wallet_onboarding_app_title = UBLocalized.tr(UBLocalizedKey.wallet_onboarding_app_title_key)
  /// Datenschutzerklärung &\nNutzungsbedingungen
   static let wallet_onboarding_external_privacy_button = UBLocalized.tr(UBLocalizedKey.wallet_onboarding_external_privacy_button_key)
  /// Nutzungsbedingungen
   static let wallet_onboarding_privacy_conditionsofuse_title = UBLocalized.tr(UBLocalizedKey.wallet_onboarding_privacy_conditionsofuse_title_key)
  /// Datenschutz
   static let wallet_onboarding_privacy_header = UBLocalized.tr(UBLocalizedKey.wallet_onboarding_privacy_header_key)
  /// Grünes Schild mit Häkchen
   static let wallet_onboarding_privacy_icon1 = UBLocalized.tr(UBLocalizedKey.wallet_onboarding_privacy_icon1_key)
  /// Datenschutzerklärung
   static let wallet_onboarding_privacy_privacypolicy_title = UBLocalized.tr(UBLocalizedKey.wallet_onboarding_privacy_privacypolicy_title_key)
  /// Die Zertifikate sind nur lokal auf Ihrem Smartphone hinterlegt. Die Daten werden nicht in einem zentralen System gespeichert.
   static let wallet_onboarding_privacy_text = UBLocalized.tr(UBLocalizedKey.wallet_onboarding_privacy_text_key)
  /// Ihre Daten bleiben \nin der App
   static let wallet_onboarding_privacy_title = UBLocalized.tr(UBLocalizedKey.wallet_onboarding_privacy_title_key)
  /// Vorteile
   static let wallet_onboarding_show_header = UBLocalized.tr(UBLocalizedKey.wallet_onboarding_show_header_key)
  /// QR Code
   static let wallet_onboarding_show_icon1 = UBLocalized.tr(UBLocalizedKey.wallet_onboarding_show_icon1_key)
  /// Grünes Häkchen
   static let wallet_onboarding_show_icon2 = UBLocalized.tr(UBLocalizedKey.wallet_onboarding_show_icon2_key)
  /// Die auf dem Zertifikat dargestellten Daten sind auch im EU-konformen QR-Code enthalten.
   static let wallet_onboarding_show_text1 = UBLocalized.tr(UBLocalizedKey.wallet_onboarding_show_text1_key)
  /// Beim Vorweisen wird der EU-konforme QR-Code mit einer Prüfanwendung gescannt. Die enthaltenen Daten werden dabei automatisch auf Echtheit und Gültigkeit überprüft.
   static let wallet_onboarding_show_text2 = UBLocalized.tr(UBLocalizedKey.wallet_onboarding_show_text2_key)
  /// Zertifikate einfach vorweisen
   static let wallet_onboarding_show_title = UBLocalized.tr(UBLocalizedKey.wallet_onboarding_show_title_key)
  /// Vorteile
   static let wallet_onboarding_store_header = UBLocalized.tr(UBLocalizedKey.wallet_onboarding_store_header_key)
  /// Schloss
   static let wallet_onboarding_store_icon1 = UBLocalized.tr(UBLocalizedKey.wallet_onboarding_store_icon1_key)
  /// Die EU-konformen Zertifikate des Grünen Passes können einfach zur App hinzugefügt und digital aufbewahrt werden.
   static let wallet_onboarding_store_text1 = UBLocalized.tr(UBLocalizedKey.wallet_onboarding_store_text1_key)
  /// EU-konforme Zertifikate digital aufbewahren
   static let wallet_onboarding_store_title = UBLocalized.tr(UBLocalizedKey.wallet_onboarding_store_title_key)
  /// Je nach Bundesland können andere Zutrittsregeln gelten. Sie können das Bundesland jederzeit ändern.
   static let wallet_region_selection_header_message = UBLocalized.tr(UBLocalizedKey.wallet_region_selection_header_message_key)
  /// Bundesland wählen
   static let wallet_region_selection_header_title = UBLocalized.tr(UBLocalizedKey.wallet_region_selection_header_title_key)
  /// Bundeslandauswahl
   static let wallet_region_selection_title = UBLocalized.tr(UBLocalizedKey.wallet_region_selection_title_key)
  /// Erneut scannen
   static let wallet_scan_again = UBLocalized.tr(UBLocalizedKey.wallet_scan_again_key)
  /// Scannen Sie den EU-konformen QR-Code auf dem Zertifikat.
   static let wallet_scanner_explanation = UBLocalized.tr(UBLocalizedKey.wallet_scanner_explanation_key)
  /// Alle EU-konformen Zertifikate des Grünen Passes können mittels Handy-Signatur oder Bürgerkarte über gesundheit.gv.at abgerufen werden.
   static let wallet_scanner_howitworks_answer1 = UBLocalized.tr(UBLocalizedKey.wallet_scanner_howitworks_answer1_key)
  /// https://gruenerpass.gv.at/
   static let wallet_scanner_howitworks_external_link = UBLocalized.tr(UBLocalizedKey.wallet_scanner_howitworks_external_link_key)
  /// Weitere Informationen
   static let wallet_scanner_howitworks_external_link_title = UBLocalized.tr(UBLocalizedKey.wallet_scanner_howitworks_external_link_title_key)
  /// So funktioniert's
   static let wallet_scanner_howitworks_header = UBLocalized.tr(UBLocalizedKey.wallet_scanner_howitworks_header_key)
  /// Erster Schritt
   static let wallet_scanner_howitworks_icon1 = UBLocalized.tr(UBLocalizedKey.wallet_scanner_howitworks_icon1_key)
  /// Zweiter Schritt
   static let wallet_scanner_howitworks_icon2 = UBLocalized.tr(UBLocalizedKey.wallet_scanner_howitworks_icon2_key)
  /// Dritter Schritt
   static let wallet_scanner_howitworks_icon3 = UBLocalized.tr(UBLocalizedKey.wallet_scanner_howitworks_icon3_key)
  /// Wie und wo erhalte ich ein EU-konformes Zertifikat?
   static let wallet_scanner_howitworks_question1 = UBLocalized.tr(UBLocalizedKey.wallet_scanner_howitworks_question1_key)
  /// Um ein Zertifikat zur App hinzufügen zu können, benötigen Sie das Originalzertifikat auf Papier oder als PDF.
   static let wallet_scanner_howitworks_text1 = UBLocalized.tr(UBLocalizedKey.wallet_scanner_howitworks_text1_key)
  /// Tippen Sie in der App auf «Hinzufügen», um ein neues Zertifikat zur App hinzuzufügen.
   static let wallet_scanner_howitworks_text2 = UBLocalized.tr(UBLocalizedKey.wallet_scanner_howitworks_text2_key)
  /// Halten Sie nun die Kamera des Smartphones über den EU-konformen QR-Code auf dem Zertifikat, um diesen zu scannen.
   static let wallet_scanner_howitworks_text3 = UBLocalized.tr(UBLocalizedKey.wallet_scanner_howitworks_text3_key)
  /// Es erscheint eine Vorschau des Zertifikats. Tippen Sie auf «Hinzufügen» um das Zertifikat sicher in der App zu speichern.
   static let wallet_scanner_howitworks_text4 = UBLocalized.tr(UBLocalizedKey.wallet_scanner_howitworks_text4_key)
  /// Zertifikate\nhinzufügen
   static let wallet_scanner_howitworks_title = UBLocalized.tr(UBLocalizedKey.wallet_scanner_howitworks_title_key)
  /// So funktioniert's
   static let wallet_scanner_info_button = UBLocalized.tr(UBLocalizedKey.wallet_scanner_info_button_key)
  /// Hinzufügen
   static let wallet_scanner_title = UBLocalized.tr(UBLocalizedKey.wallet_scanner_title_key)
  /// https://gruenerpass.gv.at/app/datenschutz
   static let wallet_terms_privacy_link = UBLocalized.tr(UBLocalizedKey.wallet_terms_privacy_link_key)
  /// 3-G Status nicht verfügbar, bitte aktivieren Sie die Internetverbindung
   static let wallet_time_missing = UBLocalized.tr(UBLocalizedKey.wallet_time_missing_key)
  /// 3-G Status nicht verfügbar, bitte aktivieren Sie die Internetverbindung
   static let wallet_validation_data_expired = UBLocalized.tr(UBLocalizedKey.wallet_validation_data_expired_key)
  /// Bildschirmaufnahme ist nicht erlaubt!
   static let warning_screen_recording = UBLocalized.tr(UBLocalizedKey.warning_screen_recording_key)
}
// swiftlint:enable function_parameter_count identifier_name line_length type_body_length

// MARK: - Implementation Details

extension UBLocalized {
  private static func tr(_ key: UBLocalizedKey, _ table: String = "Localizable", _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key.rawValue, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

extension UBLocalized {
  public static func translate(_ key: UBLocalizedKey, languageKey: String? = nil, table: String = "Localizable", _ args: CVarArg...) -> String {
    guard let languageKey = languageKey else {
      return tr(key, table, args)
    }

    guard let bundlePath = BundleToken.bundle.path(forResource: languageKey, ofType: "lproj"), let bundle = Bundle(path: bundlePath)
    else { return "" }
    return String(format: NSLocalizedString(key.rawValue, bundle: bundle, value: "", comment: ""), locale: Locale.current, arguments: args)
  }
}


// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
