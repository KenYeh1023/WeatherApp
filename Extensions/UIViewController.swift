
import UIKit

extension UIViewController {
    //顯示讀取畫面
    func presentLoadingView() {
        let loadingViewController = storyboard?.instantiateViewController(withIdentifier: "loadingViewController") as? LoadingViewController
        guard loadingViewController != nil else { return }
        loadingViewController?.modalTransitionStyle = .flipHorizontal
        loadingViewController?.modalPresentationStyle = .overCurrentContext
        present(loadingViewController!, animated: true)
    }
}
