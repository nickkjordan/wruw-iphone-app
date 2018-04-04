import Foundation
import Social

class SocialComposeViewController: SLComposeViewController {
    var alertWindow: UIWindow?

    func show(animated: Bool = true, completion: (() -> Void)? = nil) {
        alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow?.rootViewController = UIViewController()

        let topWindow = UIApplication.shared.windows.last

        alertWindow?.windowLevel = topWindow?.windowLevel ?? 0 + 1

        alertWindow?.makeKeyAndVisible()
        alertWindow?.rootViewController?
            .present(self, animated: animated, completion: completion)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        alertWindow?.isHidden = true
        alertWindow = nil
    }
}
