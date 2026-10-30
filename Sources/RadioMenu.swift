// Radio Menu — Copyright (C) 2026 Kalk
// Website: https://cialu.net | Code: https://github.com/cialu-net
// SPDX-License-Identifier: GPL-3.0-only
// Distributed under the GNU General Public License version 3, without warranty.

import SwiftUI
import AVFoundation
import AppKit
import Combine

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
        "it": ["credits":"Crediti", "author":"Autore", "site":"Sito", "code":"Codice", "license":"Licenza", "settings":"Impostazioni…", "title":"Impostazioni", "language":"Lingua", "system":"Lingua del sistema", "animated":"Icona animata durante la riproduzione", "resume":"Riproduci l’ultima stazione all’avvio"],
        "en": ["credits":"Credits", "author":"Author", "site":"Website", "code":"Code", "license":"License", "settings":"Settings…", "title":"Settings", "language":"Language", "system":"System language", "animated":"Animate icon during playback", "resume":"Play last station on launch"],
        "es": ["credits":"Créditos", "author":"Autor", "site":"Sitio web", "code":"Código", "license":"Licencia", "settings":"Ajustes…", "title":"Ajustes", "language":"Idioma", "system":"Idioma del sistema", "animated":"Animar el icono durante la reproducción", "resume":"Reproducir la última emisora al iniciar"],
        "de": ["credits":"Mitwirkende", "author":"Autor", "site":"Website", "code":"Quellcode", "license":"Lizenz", "settings":"Einstellungen…", "title":"Einstellungen", "language":"Sprache", "system":"Systemsprache", "animated":"Symbol während der Wiedergabe animieren", "resume":"Letzten Sender beim Start wiedergeben"],
        "fr": ["credits":"Crédits", "author":"Auteur", "site":"Site web", "code":"Code", "license":"Licence", "settings":"Réglages…", "title":"Réglages", "language":"Langue", "system":"Langue du système", "animated":"Animer l’icône pendant la lecture", "resume":"Lire la dernière station au démarrage"],
        "zh": ["credits":"鸣谢", "author":"作者", "site":"网站", "code":"源代码", "license":"许可证", "settings":"设置…", "title":"设置", "language":"语言", "system":"系统语言", "animated":"播放时显示动画图标", "resume":"启动时播放上次收听的电台"]
    ]
    static func text(_ key: String) -> String { settingsTranslations[language]?[key] ?? translations[language]?[key] ?? settingsTranslations["en"]?[key] ?? translations["en"]?[key] ?? key }
    static func format(_ key: String, _ value: String) -> String { String(format: text(key), value) }
}

struct Station: Identifiable, Codable {
    var id = UUID()
    var name: String
    var url: String
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
        player?.pause()
        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        player?.volume = Float(volume)
        current = station.id
        UserDefaults.standard.set(station.id.uuidString, forKey: "lastStation")
        setStatus("connecting", station: station.name)
        observation = item.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
            DispatchQueue.main.async {
                guard let self = self, self.current == station.id else { return }
                if item.status == .readyToPlay { self.setStatus("playing", station: station.name); self.startAnimation() }
                else if item.status == .failed { self.setStatus("failed"); self.timer?.invalidate(); self.timer = nil; self.current = nil }
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
    func stop() { timer?.invalidate(); timer = nil; observation = nil; player?.pause(); player = nil; current = nil; setStatus("stopped") }
    func remove(_ station: Station) { if current == station.id { stop() }; stations.removeAll { $0.id == station.id } }
}

struct RadioView: View {
    @ObservedObject var radio: Radio
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack { Image(systemName: "radio.fill").foregroundStyle(.tint); Text("Radio Menu").font(.headline); Spacer(); Button(L.text("quit")) { NSApplication.shared.terminate(nil) }.buttonStyle(.borderless) }
            Text(radio.status).font(.caption).foregroundStyle(.secondary).lineLimit(2)
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
            Divider()
            Text(L.text("credits")).font(.headline)
            Grid(alignment: .leading, horizontalSpacing: 14, verticalSpacing: 6) {
                GridRow { Text(L.text("author")); Text("Kalk") }
                GridRow { Text(L.text("site")); Link("cialu.net", destination: URL(string: "https://cialu.net")!) }
                GridRow { Text(L.text("code")); Link("github.com/cialu-net", destination: URL(string: "https://github.com/cialu-net")!) }
                GridRow { Text(L.text("license")); Link("GNU GPL v3", destination: URL(string: "https://www.gnu.org/licenses/gpl-3.0.html")!) }
            }.font(.callout)
            Spacer(minLength: 0)
        }.padding(24).frame(width: 440, height: 370)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let radio = Radio()
    private var statusItem: NSStatusItem!
    private let popover = NSPopover()
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
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: RadioView(radio: radio))
        radio.objectWillChange.receive(on: RunLoop.main).sink { [weak self] _ in
            guard let self = self else { return }
            self.statusItem.button?.image = self.radio.icon
            self.settingsWindow?.title = L.text("title")
        }.store(in: &subscriptions)
        radio.resumeLastStation()
    }
    @objc private func statusClicked(_ sender: NSStatusBarButton) {
        if NSApp.currentEvent?.type == .rightMouseUp {
            popover.performClose(nil)
            let menu = NSMenu()
            let settings = NSMenuItem(title: L.text("settings"), action: #selector(showSettings), keyEquivalent: ",")
            settings.target = self
            menu.addItem(settings)
            menu.addItem(.separator())
            let quit = NSMenuItem(title: L.text("quit"), action: #selector(quitApp), keyEquivalent: "q")
            quit.target = self
            menu.addItem(quit)
            statusItem.menu = menu
            sender.performClick(nil)
            statusItem.menu = nil
        } else if popover.isShown { popover.performClose(nil) }
        else { popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY) }
    }
    @objc private func showSettings() {
        popover.performClose(nil)
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
