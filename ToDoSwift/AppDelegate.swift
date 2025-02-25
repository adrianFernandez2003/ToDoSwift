import UIKit
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        requestNotificationPermission()
        
        // Start polling for routine schedules after permissions are granted
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                if settings.authorizationStatus == .authorized {
                    self.sendTestNotification()
                    startPollingForRoutineSchedules() // Start polling after permissions are confirmed
                } else {
                    print("❌ No se pueden enviar notificaciones: permisos denegados")
                }
            }
        }

        return true
    }
    
    func requestNotificationPermission() {
        DispatchQueue.main.async {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                DispatchQueue.main.async {
                    if granted {
                        print("✅ Permisos de notificaciones concedidos")
                    } else {
                        print("❌ Permiso denegado")
                    }
                }
            }
        }
    }

    
    func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "📢 Notificación de Prueba"
        content.body = "Si ves esto, las notificaciones funcionan 🎉"
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        print("📨 Intentando programar la notificación...")

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error al programar la notificación: \(error.localizedDescription)")
            } else {
                print("✅ Notificación programada en 5 segundos")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
