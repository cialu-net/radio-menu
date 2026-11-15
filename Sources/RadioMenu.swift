// Radio Menu — Copyright (C) 2026 Kalk
// Version: see CFBundleShortVersionString in Resources/Info.plist
// Website: https://cialu.net | Code: https://github.com/cialu-net
// SPDX-License-Identifier: GPL-3.0-only
// Distributed under the GNU General Public License version 3, without warranty.

import SwiftUI
import AVFoundation
import AppKit
import Combine
import ServiceManagement
import UniformTypeIdentifiers

enum L {
    static var language: String {
        let selected = UserDefaults.standard.string(forKey: "language") ?? "system"
        if ["it", "en", "es", "de", "fr", "zh"].contains(selected) { return selected }
        return Locale.preferredLanguages.map { String($0.split(separator: "-").first ?? "en") }.first { ["it", "en", "es", "de", "fr", "zh"].contains($0) } ?? "en"
    }
    static let translations: [String: [String: String]] = [
        "it": ["choose":"Scegli una stazione", "connecting":"Connessione a %@…", "playing":"In riproduzione: %@", "failed":"Impossibile riprodurre la stazione", "invalid":"Indirizzo non valido", "stopped":"Riproduzione interrotta", "quit":"Esci", "empty":"Nessuna stazione. Aggiungine una qui sotto.", "delete":"Elimina stazione", "stop":"Stop", "volume":"Volume", "name":"Nome della radio", "url":"URL diretto dello stream (HTTPS o HTTP)", "cancel":"Annulla", "save":"Salva", "add":"Aggiungi stazione", "validation":"Inserisci un nome e un URL HTTP o HTTPS valido."],
        "en": ["choose":"Choose a station", "connecting":"Connecting to %@…", "playing":"Playing: %@", "failed":"Unable to play the station", "invalid":"Invalid address", "stopped":"Playback stopped", "quit":"Quit", "empty":"No stations yet. Add one below.", "delete":"Delete station", "stop":"Stop", "volume":"Volume", "name":"Station name", "url":"Direct stream URL (HTTPS or HTTP)", "cancel":"Cancel", "save":"Save", "add":"Add station", "validation":"Enter a name and a valid HTTP or HTTPS URL."],
        "es": ["choose":"Elige una emisora", "connecting":"Conectando con %@…", "playing":"Reproduciendo: %@", "failed":"No se puede reproducir la emisora", "invalid":"Dirección no válida", "stopped":"Reproducción detenida", "quit":"Salir", "empty":"No hay emisoras. Añade una a continuación.", "delete":"Eliminar emisora", "stop":"Detener", "volume":"Volumen", "name":"Nombre de la emisora", "url":"URL directa de la emisión (HTTPS o HTTP)", "cancel":"Cancelar", "save":"Guardar", "add":"Añadir emisora", "validation":"Introduce un nombre y una URL HTTP o HTTPS válida."],
        "de": ["choose":"Sender auswählen", "connecting":"Verbindung mit %@ wird hergestellt…", "playing":"Wiedergabe: %@", "failed":"Sender kann nicht wiedergegeben werden", "invalid":"Ungültige Adresse", "stopped":"Wiedergabe gestoppt", "quit":"Beenden", "empty":"Keine Sender vorhanden. Füge unten einen hinzu.", "delete":"Sender löschen", "stop":"Stopp", "volume":"Lautstärke", "name":"Sendername", "url":"Direkte Stream-URL (HTTPS oder HTTP)", "cancel":"Abbrechen", "save":"Sichern", "add":"Sender hinzufügen", "validation":"Gib einen Namen und eine gültige HTTP- oder HTTPS-URL ein."],
        "fr": ["choose":"Choisissez une station", "connecting":"Connexion à %@…", "playing":"En lecture : %@", "failed":"Impossible de lire la station", "invalid":"Adresse invalide", "stopped":"Lecture arrêtée", "quit":"Quitter", "empty":"Aucune station. Ajoutez-en une ci-dessous.", "delete":"Supprimer la station", "stop":"Arrêter", "volume":"Volume", "name":"Nom de la station", "url":"URL directe du flux (HTTPS ou HTTP)", "cancel":"Annuler", "save":"Enregistrer", "add":"Ajouter une station", "validation":"Saisissez un nom et une URL HTTP ou HTTPS valide."],
        "zh": ["choose":"选择电台", "connecting":"正在连接 %@…", "playing":"正在播放：%@", "failed":"无法播放此电台", "invalid":"地址无效", "stopped":"播放已停止", "quit":"退出", "empty":"暂无电台，请在下方添加。", "delete":"删除电台", "stop":"停止", "volume":"音量", "name":"电台名称", "url":"直播流直链（HTTPS 或 HTTP）", "cancel":"取消", "save":"保存", "add":"添加电台", "validation":"请输入名称和有效的 HTTP 或 HTTPS 地址。"]
    ]
    static let settingsTranslations: [String: [String: String]] = [
        "it": ["login":"Avvia Radio Menu al login", "loginApproval":"Per completare l’attivazione, consenti Radio Menu negli Elementi login di macOS.", "loginOpen":"Apri Elementi login", "loginError":"Impossibile modificare l’avvio al login. Verifica gli Elementi login nelle impostazioni di macOS.", "version":"Versione", "credits":"Crediti", "author":"Autore", "site":"Sito", "code":"Codice", "license":"Licenza", "settings":"Impostazioni…", "title":"Impostazioni", "language":"Lingua", "system":"Lingua del sistema", "animated":"Icona animata durante la riproduzione", "resume":"Riproduci l’ultima stazione all’avvio"],
        "en": ["login":"Launch Radio Menu at login", "loginApproval":"To finish enabling, allow Radio Menu in macOS Login Items.", "loginOpen":"Open Login Items", "loginError":"Could not change launch at login. Check Login Items in macOS settings.", "version":"Version", "credits":"Credits", "author":"Author", "site":"Website", "code":"Code", "license":"License", "settings":"Settings…", "title":"Settings", "language":"Language", "system":"System language", "animated":"Animate icon during playback", "resume":"Play last station on launch"],
        "es": ["login":"Abrir Radio Menu al iniciar sesión", "loginApproval":"Para completar la activación, permite Radio Menu en Ítems de inicio de macOS.", "loginOpen":"Abrir Ítems de inicio", "loginError":"No se pudo cambiar el inicio automático. Comprueba los ítems de inicio de macOS.", "version":"Versión", "credits":"Créditos", "author":"Autor", "site":"Sitio web", "code":"Código", "license":"Licencia", "settings":"Ajustes…", "title":"Ajustes", "language":"Idioma", "system":"Idioma del sistema", "animated":"Animar el icono durante la reproducción", "resume":"Reproducir la última emisora al iniciar"],
        "de": ["login":"Radio Menu bei der Anmeldung öffnen", "loginApproval":"Erlaube Radio Menu unter den macOS-Anmeldeobjekten, um die Aktivierung abzuschließen.", "loginOpen":"Anmeldeobjekte öffnen", "loginError":"Start bei der Anmeldung konnte nicht geändert werden. Prüfe die macOS-Anmeldeobjekte.", "version":"Version", "credits":"Mitwirkende", "author":"Autor", "site":"Website", "code":"Quellcode", "license":"Lizenz", "settings":"Einstellungen…", "title":"Einstellungen", "language":"Sprache", "system":"Systemsprache", "animated":"Symbol während der Wiedergabe animieren", "resume":"Letzten Sender beim Start wiedergeben"],
        "fr": ["login":"Ouvrir Radio Menu à l’ouverture de session", "loginApproval":"Pour terminer l’activation, autorisez Radio Menu dans les éléments d’ouverture de macOS.", "loginOpen":"Ouvrir les éléments d’ouverture", "loginError":"Impossible de modifier le lancement à l’ouverture de session. Vérifiez les réglages macOS.", "version":"Version", "credits":"Crédits", "author":"Auteur", "site":"Site web", "code":"Code", "license":"Licence", "settings":"Réglages…", "title":"Réglages", "language":"Langue", "system":"Langue du système", "animated":"Animer l’icône pendant la lecture", "resume":"Lire la dernière station au démarrage"],
        "zh": ["login":"登录时启动 Radio Menu", "loginApproval":"要完成启用，请在 macOS 登录项中允许 Radio Menu。", "loginOpen":"打开登录项", "loginError":"无法更改登录时启动设置。请检查 macOS 登录项。", "version":"版本", "credits":"鸣谢", "author":"作者", "site":"网站", "code":"源代码", "license":"许可证", "settings":"设置…", "title":"设置", "language":"语言", "system":"系统语言", "animated":"播放时显示动画图标", "resume":"启动时播放上次收听的电台"]
    ]
    static let libraryTranslations: [String: [String: String]] = [
        "it": ["export":"Esporta stazioni…", "import":"Importa stazioni…", "exportError":"Impossibile esportare le stazioni.", "importError":"Impossibile importare il file: formato non valido o nessuna stazione valida.", "importTitle":"Importa stazioni", "importMessage":"Trovate %@ stazioni valide. Vuoi aggiungerle a quelle esistenti o sostituire la lista?", "merge":"Aggiungi", "replace":"Sostituisci"],
        "en": ["export":"Export Stations…", "import":"Import Stations…", "exportError":"Could not export the stations.", "importError":"Could not import the file: invalid format or no valid stations.", "importTitle":"Import Stations", "importMessage":"Found %@ valid stations. Add them to your current list or replace it?", "merge":"Add", "replace":"Replace"],
        "es": ["export":"Exportar emisoras…", "import":"Importar emisoras…", "exportError":"No se pudieron exportar las emisoras.", "importError":"No se pudo importar el archivo: formato no válido o sin emisoras válidas.", "importTitle":"Importar emisoras", "importMessage":"Se han encontrado %@ emisoras válidas. ¿Añadirlas a la lista actual o sustituirla?", "merge":"Añadir", "replace":"Sustituir"],
        "de": ["export":"Sender exportieren…", "import":"Sender importieren…", "exportError":"Die Sender konnten nicht exportiert werden.", "importError":"Die Datei konnte nicht importiert werden: ungültiges Format oder keine gültigen Sender.", "importTitle":"Sender importieren", "importMessage":"%@ gültige Sender gefunden. Zur aktuellen Liste hinzufügen oder die Liste ersetzen?", "merge":"Hinzufügen", "replace":"Ersetzen"],
        "fr": ["export":"Exporter les stations…", "import":"Importer des stations…", "exportError":"Impossible d’exporter les stations.", "importError":"Impossible d’importer le fichier : format invalide ou aucune station valide.", "importTitle":"Importer des stations", "importMessage":"%@ stations valides trouvées. Les ajouter à la liste actuelle ou la remplacer ?", "merge":"Ajouter", "replace":"Remplacer"],
        "zh": ["export":"导出电台…", "import":"导入电台…", "exportError":"无法导出电台。", "importError":"无法导入该文件：格式无效或没有有效的电台。", "importTitle":"导入电台", "importMessage":"找到 %@ 个有效电台。要添加到当前列表还是替换列表？", "merge":"添加", "replace":"替换"]
    ]
    static func text(_ key: String) -> String { settingsTranslations[language]?[key] ?? translations[language]?[key] ?? libraryTranslations[language]?[key] ?? settingsTranslations["en"]?[key] ?? translations["en"]?[key] ?? libraryTranslations["en"]?[key] ?? key }
    static func format(_ key: String, _ value: String) -> String { String(format: text(key), value) }
}

struct Station: Identifiable, Codable {
    var id = UUID()
    var name: String
    var url: String
}

// Portable representation used for exporting/importing the station list.
struct StationEntry: Codable { var name: String; var url: String }
struct StationFile: Codable { var version: Int; var stations: [StationEntry] }

// Receives timed metadata (ICY StreamTitle, ID3…) from the current stream.
final class MetadataReceiver: NSObject, AVPlayerItemMetadataOutputPushDelegate {
    var onGroups: (([AVTimedMetadataGroup]) -> Void)?
    func metadataOutput(_ output: AVPlayerItemMetadataOutput, didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup], from track: AVPlayerItemTrack?) {
        onGroups?(groups)
    }
}

final class Radio: ObservableObject {
    @Published var stations: [Station] { didSet { save() } }
    @Published var language = UserDefaults.standard.string(forKey: "language") ?? "system" {
        didSet { UserDefaults.standard.set(language, forKey: "language"); updateStatus() }
    }
    @Published var animated = UserDefaults.standard.object(forKey: "animated") as? Bool ?? true {
        didSet { UserDefaults.standard.set(animated, forKey: "animated"); if !animated { timer?.invalidate(); timer = nil } else if player?.currentItem?.status == .readyToPlay && current != nil { startAnimation() } }
    }
    @Published var resumeOnLaunch = UserDefaults.standard.bool(forKey: "resumeOnLaunch") {
        didSet { UserDefaults.standard.set(resumeOnLaunch, forKey: "resumeOnLaunch") }
    }
    @Published private(set) var launchAtLogin = false
    @Published private(set) var loginNeedsApproval = false
    @Published private(set) var loginError = false

    func refreshLoginStatus() {
        let state = SMAppService.mainApp.status
        launchAtLogin = state == .enabled || state == .requiresApproval
        loginNeedsApproval = state == .requiresApproval
    }
    func setLaunchAtLogin(_ enabled: Bool) {
        loginError = false
        do {
            if enabled { try SMAppService.mainApp.register() }
            else { try SMAppService.mainApp.unregister() }
            refreshLoginStatus()
        } catch {
            refreshLoginStatus()
            if !loginNeedsApproval { loginError = true }
        }
    }
    private var statusKey = "choose"
    private var statusStation = ""
    private func setStatus(_ key: String, station: String = "") { statusKey = key; statusStation = station; updateStatus() }
    private func updateStatus() { status = statusStation.isEmpty ? L.text(statusKey) : L.format(statusKey, statusStation) }
    func resumeLastStation() {
        guard resumeOnLaunch, let id = UserDefaults.standard.string(forKey: "lastStation"), let station = stations.first(where: { $0.id.uuidString == id }) else { return }
        play(station)
    }
    @Published var adding = false
    @Published var name = ""
    @Published var address = ""
    @Published var error = ""
    @Published var current: UUID?
    @Published var status = L.text("choose")
    @Published var frame = 0
    @Published private(set) var artist = ""
    @Published private(set) var songTitle = ""
    private var metadataOutput: AVPlayerItemMetadataOutput?
    private var metadataReceiver: MetadataReceiver?
    private var timer: Timer?
    @Published var volume: Double = 0.7 { didSet { player?.volume = Float(volume); UserDefaults.standard.set(volume, forKey: "volume") } }
    private var player: AVPlayer?
    private var observation: NSKeyValueObservation?
    init() {
        let defaults = UserDefaults.standard
        let presets = [
            Station(name: "Absolute Chillout", url: "https://streaming.live365.com/b05055_128mp3"),
            Station(name: "Sound Of Berlin", url: "https://channels.fluxfm.de/sound-of-berlin/externalembedflxhp/stream.mp3"),
            Station(name: "Techno Underground", url: "https://channels.fluxfm.de/techno-underground/externalembedflxhp/stream.mp3")
        ]
        if let data = defaults.data(forKey: "stations"), let saved = try? JSONDecoder().decode([Station].self, from: data) {
            stations = saved
            if !defaults.bool(forKey: "presets2026Added") {
                for preset in presets where !stations.contains(where: { $0.name.caseInsensitiveCompare(preset.name) == .orderedSame || $0.url == preset.url }) {
                    stations.append(preset)
                }
            }
        } else {
            stations = presets
        }
        if !defaults.bool(forKey: "presets2026Added") {
            save()
            defaults.set(true, forKey: "presets2026Added")
        }
        if defaults.object(forKey: "volume") != nil { volume = defaults.double(forKey: "volume") }
    }
    private func save() { if let data = try? JSONEncoder().encode(stations) { UserDefaults.standard.set(data, forKey: "stations") } }
    func play(_ station: Station) {
        guard let url = URL(string: station.url) else { setStatus("invalid"); return }
        timer?.invalidate(); timer = nil; frame = 0
        observation = nil
        clearNowPlaying()
        player?.pause()
        let item = AVPlayerItem(url: url)
        let receiver = MetadataReceiver()
        receiver.onGroups = { [weak self] groups in self?.handleMetadata(groups, stationID: station.id) }
        let output = AVPlayerItemMetadataOutput(identifiers: nil)
        output.setDelegate(receiver, queue: .main)
        item.add(output)
        metadataReceiver = receiver
        metadataOutput = output
        player = AVPlayer(playerItem: item)
        player?.volume = Float(volume)
        current = station.id
        UserDefaults.standard.set(station.id.uuidString, forKey: "lastStation")
        setStatus("connecting", station: station.name)
        observation = item.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
            DispatchQueue.main.async {
                guard let self = self, self.current == station.id else { return }
                if item.status == .readyToPlay { self.setStatus("playing", station: station.name); self.startAnimation() }
                else if item.status == .failed { self.setStatus("failed"); self.timer?.invalidate(); self.timer = nil; self.current = nil; self.clearNowPlaying() }
            }
        }
        player?.play()
    }
    func startAnimation() {
        timer?.invalidate()
        guard animated else { timer = nil; return }
        timer = Timer.scheduledTimer(withTimeInterval: 0.22, repeats: true) { [weak self] _ in self?.frame = ((self?.frame ?? 0) + 1) % 4 }
    }
    var icon: NSImage {
        if current == nil || !animated { return NSImage(systemSymbolName: "radio", accessibilityDescription: "Radio Menu")! }
        let image = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { rect in
            let heights: [[CGFloat]] = [[5, 12, 8, 15], [12, 7, 15, 8], [8, 15, 6, 12], [15, 8, 12, 5]]
            NSColor.black.setFill()
            for (i, height) in heights[self.frame].enumerated() {
                NSBezierPath(roundedRect: NSRect(x: CGFloat(i) * 4 + 1, y: 2, width: 2.5, height: height), xRadius: 1, yRadius: 1).fill()
            }
            return true
        }
        image.isTemplate = true
        return image
    }
    func stop() { timer?.invalidate(); timer = nil; observation = nil; player?.pause(); player = nil; current = nil; clearNowPlaying(); setStatus("stopped") }

    // MARK: Now playing
    private func clearNowPlaying() {
        metadataReceiver = nil; metadataOutput = nil
        if !artist.isEmpty { artist = "" }
        if !songTitle.isEmpty { songTitle = "" }
    }
    private func handleMetadata(_ groups: [AVTimedMetadataGroup], stationID: UUID) {
        guard current == stationID else { return }
        let items = groups.flatMap { $0.items }
        Task { @MainActor [weak self] in
            var artistValue: String?, titleValue: String?, streamValue: String?
            for item in items {
                guard let loaded = try? await item.load(.stringValue) else { continue }
                let value = loaded.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !value.isEmpty else { continue }
                if item.identifier == .icyMetadataStreamTitle { streamValue = value }
                else if item.commonKey == .commonKeyArtist { artistValue = value }
                else if item.commonKey == .commonKeyTitle { titleValue = value }
            }
            guard let self = self, self.current == stationID else { return }
            // Icecast/Shoutcast send a single "Artist - Title" string; other formats may provide separate fields.
            if let raw = streamValue ?? (artistValue == nil ? titleValue : nil) {
                if let range = raw.range(of: " - ") {
                    self.artist = String(raw[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
                    self.songTitle = String(raw[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                } else {
                    self.artist = ""; self.songTitle = raw
                }
            } else if artistValue != nil || titleValue != nil {
                self.artist = artistValue ?? ""; self.songTitle = titleValue ?? ""
            }
        }
    }
    var nowPlayingText: String {
        [artist, songTitle].filter { !$0.isEmpty }.joined(separator: " – ")
    }

    // MARK: Export / import
    func exportData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(StationFile(version: 1, stations: stations.map { StationEntry(name: $0.name, url: $0.url) }))
    }
    /// Accepts either {"version":1,"stations":[…]} or a bare array of {name,url}. Invalid entries are skipped.
    func decodeStations(from data: Data) throws -> [Station] {
        let decoder = JSONDecoder()
        let entries: [StationEntry]
        if let file = try? decoder.decode(StationFile.self, from: data) { entries = file.stations }
        else { entries = try decoder.decode([StationEntry].self, from: data) }
        return entries.compactMap { entry in
            let name = entry.name.trimmingCharacters(in: .whitespacesAndNewlines)
            let address = entry.url.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty, let url = URL(string: address), ["http", "https"].contains(url.scheme?.lowercased() ?? ""), url.host != nil else { return nil }
            return Station(name: name, url: address)
        }
    }
    func mergeStations(_ imported: [Station]) {
        var list = stations
        for station in imported where !list.contains(where: { $0.url.caseInsensitiveCompare(station.url) == .orderedSame }) { list.append(station) }
        stations = list
    }
    func replaceStations(_ imported: [Station]) {
        stop()
        stations = imported
    }
    func remove(_ station: Station) { if current == station.id { stop() }; stations.removeAll { $0.id == station.id } }
}

struct RadioView: View {
    @ObservedObject var radio: Radio
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack { Image(systemName: "radio.fill").foregroundStyle(.tint); Text("Radio Menu").font(.headline); Spacer(); Button(L.text("quit")) { NSApplication.shared.terminate(nil) }.buttonStyle(.borderless) }
            Text(radio.status).font(.caption).foregroundStyle(.secondary).lineLimit(2)
            if radio.current != nil && (!radio.songTitle.isEmpty || !radio.artist.isEmpty) {
                VStack(alignment: .leading, spacing: 2) {
                    if !radio.songTitle.isEmpty { Text(radio.songTitle).font(.subheadline.weight(.semibold)).lineLimit(2) }
                    if !radio.artist.isEmpty { Text(radio.artist).font(.callout).foregroundStyle(.secondary).lineLimit(1) }
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
            Divider()
            if radio.stations.isEmpty { Text(L.text("empty")).foregroundStyle(.secondary) }
            ScrollView { VStack(spacing: 3) {
                ForEach(radio.stations) { station in
                    HStack {
                        Button { radio.play(station) } label: { HStack { Image(systemName: radio.current == station.id ? "speaker.wave.2.fill" : "play.circle"); Text(station.name).lineLimit(1); Spacer() }.contentShape(Rectangle()) }.buttonStyle(.plain)
                        Button { radio.remove(station) } label: { Image(systemName: "trash").foregroundStyle(.secondary) }.buttonStyle(.borderless).help(L.text("delete"))
                    }.frame(minHeight: 34)
                }
            }}.frame(height: min(CGFloat(radio.stations.count) * 37, 200))
            Divider()
            HStack { Button { radio.stop() } label: { Label(L.text("stop"), systemImage: "stop.fill") }.disabled(radio.current == nil); Image(systemName: "speaker.fill"); Slider(value: $radio.volume, in: 0...1).accessibilityLabel(L.text("volume")); Image(systemName: "speaker.wave.3.fill") }
            if radio.adding {
                TextField(L.text("name"), text: $radio.name)
                TextField(L.text("url"), text: $radio.address)
                if !radio.error.isEmpty { Text(radio.error).font(.caption).foregroundStyle(.red) }
                HStack { Button(L.text("cancel")) { radio.adding = false; radio.error = "" }; Spacer(); Button(L.text("save")) { add() }.keyboardShortcut(.defaultAction) }
            } else { Button { radio.adding = true } label: { Label(L.text("add"), systemImage: "plus") }.buttonStyle(.borderless) }
        }.padding(16).frame(width: 340)
    }
    func add() {
        let n = radio.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let a = radio.address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !n.isEmpty, let url = URL(string: a), ["http", "https"].contains(url.scheme?.lowercased() ?? ""), url.host != nil else { radio.error = L.text("validation"); return }
        radio.stations.append(Station(name: n, url: a)); radio.name = ""; radio.address = ""; radio.error = ""; radio.adding = false
    }
}

struct SettingsView: View {
    @ObservedObject var radio: Radio
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(L.text("title")).font(.title2.bold())
            Picker(L.text("language"), selection: $radio.language) {
                Text(L.text("system")).tag("system")
                Text("English").tag("en")
                Text("Español").tag("es")
                Text("Deutsch").tag("de")
                Text("Français").tag("fr")
                Text("Italiano").tag("it")
                Text("简体中文").tag("zh")
            }.frame(maxWidth: 330)
            Toggle(L.text("animated"), isOn: $radio.animated)
            Toggle(L.text("resume"), isOn: $radio.resumeOnLaunch)
            Toggle(L.text("login"), isOn: Binding(get: { radio.launchAtLogin }, set: { radio.setLaunchAtLogin($0) }))
            if radio.loginNeedsApproval {
                Text(L.text("loginApproval")).font(.caption).foregroundStyle(.secondary)
                Button(L.text("loginOpen")) { SMAppService.openSystemSettingsLoginItems() }
            } else if radio.loginError {
                Text(L.text("loginError")).font(.caption).foregroundStyle(.red)
                Button(L.text("loginOpen")) { SMAppService.openSystemSettingsLoginItems() }
            }
            Divider()
            Text(L.text("credits")).font(.headline)
            Grid(alignment: .leading, horizontalSpacing: 14, verticalSpacing: 6) {
                GridRow { Text(L.text("version")); Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—") }
                GridRow { Text(L.text("author")); Text("Kalk") }
                GridRow { Text(L.text("site")); Link("cialu.net", destination: URL(string: "https://cialu.net")!) }
                GridRow { Text(L.text("code")); Link("github.com/cialu-net", destination: URL(string: "https://github.com/cialu-net")!) }
                GridRow { Text(L.text("license")); Link("GNU GPL v3", destination: URL(string: "https://www.gnu.org/licenses/gpl-3.0.html")!) }
            }.font(.callout)
            Spacer(minLength: 0)
        }.padding(24).frame(width: 470, height: 530)
            .onAppear { radio.refreshLoginStatus() }
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in radio.refreshLoginStatus() }
    }
}

// A key-capable, non-activating panel keeps text fields usable without
// activating the whole app. Escape closes the panel like a menu.
final class RadioPanel: NSPanel {
    var onEscape: (() -> Void)?
    override var canBecomeKey: Bool { true }
    override func cancelOperation(_ sender: Any?) { onEscape?() }
}

// Position below the menu bar before showing; clamp to the target display.
func radioPanelFrame(size: NSSize, anchor: NSRect, visible: NSRect) -> NSRect {
    let margin: CGFloat = 4
    let minX = visible.minX + margin
    let maxX = max(minX, visible.maxX - size.width - margin)
    let x = min(max(anchor.midX - size.width / 2, minX), maxX)
    let top = min(anchor.minY, visible.maxY) - margin
    let y = max(visible.minY + margin, top - size.height)
    return NSRect(x: x, y: y, width: size.width, height: size.height)
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let radio = Radio()
    private var statusItem: NSStatusItem!
    private var radioPanel: RadioPanel?
    private var radioView: NSHostingView<RadioView>?
    private var localMouseMonitor: Any?
    private var globalMouseMonitor: Any?
    private var settingsWindow: NSWindow?
    private var subscriptions = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        guard let button = statusItem.button else { return }
        button.image = radio.icon
        button.toolTip = "Radio Menu"
        button.target = self
        button.action = #selector(statusClicked(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        radio.objectWillChange.receive(on: RunLoop.main).sink { [weak self] _ in
            guard let self = self else { return }
            self.statusItem.button?.image = self.radio.icon
            self.statusItem.button?.toolTip = self.radio.nowPlayingText.isEmpty ? "Radio Menu" : self.radio.nowPlayingText
            self.settingsWindow?.title = L.text("title")
            if self.radioPanel?.isVisible == true {
                DispatchQueue.main.async { [weak self] in self?.sizeAndPositionRadioPanel() }
            }
        }.store(in: &subscriptions)
        radio.resumeLastStation()
    }
    @objc private func statusClicked(_ sender: NSStatusBarButton) {
        if NSApp.currentEvent?.type == .rightMouseUp {
            hideRadioPanel()
            let menu = NSMenu()
            let settings = NSMenuItem(title: L.text("settings"), action: #selector(showSettings), keyEquivalent: ",")
            settings.target = self
            menu.addItem(settings)
            menu.addItem(.separator())
            let importItem = NSMenuItem(title: L.text("import"), action: #selector(importStations), keyEquivalent: "")
            importItem.target = self
            menu.addItem(importItem)
            let exportItem = NSMenuItem(title: L.text("export"), action: #selector(exportStations), keyEquivalent: "")
            exportItem.target = self
            menu.addItem(exportItem)
            menu.addItem(.separator())
            let quit = NSMenuItem(title: L.text("quit"), action: #selector(quitApp), keyEquivalent: "q")
            quit.target = self
            menu.addItem(quit)
            statusItem.menu = menu
            sender.performClick(nil)
            statusItem.menu = nil
        } else if radioPanel?.isVisible == true { hideRadioPanel() }
        else { showRadioPanel() }
    }
    private func makeRadioPanel() {
        let panel = RadioPanel(contentRect: NSRect(x: 0, y: 0, width: 340, height: 300),
                               styleMask: [.borderless, .nonactivatingPanel],
                               backing: .buffered, defer: false)
        panel.isReleasedWhenClosed = false
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.isFloatingPanel = true
        panel.level = .popUpMenu
        panel.animationBehavior = .none
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient, .ignoresCycle]
        panel.onEscape = { [weak self] in self?.hideRadioPanel() }
        let background = NSVisualEffectView()
        background.material = .popover
        background.blendingMode = .behindWindow
        background.state = .active
        background.wantsLayer = true
        background.layer?.cornerRadius = 12
        background.layer?.masksToBounds = true
        let view = NSHostingView(rootView: RadioView(radio: radio))
        view.translatesAutoresizingMaskIntoConstraints = false
        background.addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: background.trailingAnchor),
            view.topAnchor.constraint(equalTo: background.topAnchor),
            view.bottomAnchor.constraint(equalTo: background.bottomAnchor)
        ])
        panel.contentView = background
        radioPanel = panel
        radioView = view
    }
    private func showRadioPanel() {
        if radioPanel == nil { makeRadioPanel() }
        guard let panel = radioPanel else { return }
        // Size and position while hidden so the first visible frame is correct.
        sizeAndPositionRadioPanel()
        panel.makeKeyAndOrderFront(nil)
        installMouseMonitors()
    }
    private func sizeAndPositionRadioPanel() {
        guard let panel = radioPanel, let view = radioView,
              let button = statusItem.button, let buttonWindow = button.window,
              let screen = buttonWindow.screen else { return }
        view.layoutSubtreeIfNeeded()
        let measured = view.fittingSize
        guard measured.width > 0, measured.height > 0 else { return }
        let anchor = buttonWindow.convertToScreen(button.convert(button.bounds, to: nil))
        let frame = radioPanelFrame(size: measured, anchor: anchor, visible: screen.visibleFrame)
        if panel.frame != frame { panel.setFrame(frame, display: panel.isVisible, animate: false) }
    }
    private func installMouseMonitors() {
        removeMouseMonitors()
        let mask: NSEvent.EventTypeMask = [.leftMouseDown, .rightMouseDown, .otherMouseDown]
        localMouseMonitor = NSEvent.addLocalMonitorForEvents(matching: mask) { [weak self] event in
            self?.dismissPanelIfOutside()
            return event
        }
        globalMouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: mask) { [weak self] _ in
            DispatchQueue.main.async { self?.dismissPanelIfOutside() }
        }
    }
    private func dismissPanelIfOutside() {
        guard let panel = radioPanel, panel.isVisible else { return }
        let point = NSEvent.mouseLocation
        if panel.frame.contains(point) { return }
        if let button = statusItem.button, let window = button.window {
            let buttonFrame = window.convertToScreen(button.convert(button.bounds, to: nil))
            if buttonFrame.contains(point) { return }
        }
        hideRadioPanel()
    }
    private func removeMouseMonitors() {
        if let monitor = localMouseMonitor { NSEvent.removeMonitor(monitor); localMouseMonitor = nil }
        if let monitor = globalMouseMonitor { NSEvent.removeMonitor(monitor); globalMouseMonitor = nil }
    }
    private func hideRadioPanel() {
        radioPanel?.orderOut(nil)
        removeMouseMonitors()
    }
    @objc private func showSettings() {
        hideRadioPanel()
        radio.refreshLoginStatus()
        if settingsWindow == nil {
            let window = NSWindow(contentViewController: NSHostingController(rootView: SettingsView(radio: radio)))
            window.styleMask = [.titled, .closable, .miniaturizable]
            window.isReleasedWhenClosed = false
            window.center()
            settingsWindow = window
        }
        settingsWindow?.title = L.text("title")
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    @objc private func exportStations() {
        hideRadioPanel()
        NSApp.activate(ignoringOtherApps: true)
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "RadioMenu-stations.json"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do { try radio.exportData().write(to: url, options: .atomic) }
        catch { showError(L.text("exportError")) }
    }
    @objc private func importStations() {
        hideRadioPanel()
        NSApp.activate(ignoringOtherApps: true)
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        guard panel.runModal() == .OK, let url = panel.url else { return }
        guard let data = try? Data(contentsOf: url), let imported = try? radio.decodeStations(from: data), !imported.isEmpty else {
            showError(L.text("importError")); return
        }
        let alert = NSAlert()
        alert.messageText = L.text("importTitle")
        alert.informativeText = L.format("importMessage", String(imported.count))
        alert.addButton(withTitle: L.text("merge"))
        alert.addButton(withTitle: L.text("replace"))
        alert.addButton(withTitle: L.text("cancel"))
        switch alert.runModal() {
        case .alertFirstButtonReturn: radio.mergeStations(imported)
        case .alertSecondButtonReturn: radio.replaceStations(imported)
        default: break
        }
    }
    private func showError(_ message: String) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = message
        alert.runModal()
    }
    @objc private func quitApp() { NSApp.terminate(nil) }
}

@main struct RadioMenuApp {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        withExtendedLifetime(delegate) { app.run() }
    }
}
