import Foundation
import Alamofire

class SpotifyOAuth2Handler: RequestRetrier {
    private let lock = NSLock()

    private var isRefreshing = false
    fileprivate(set) var requestsToRetry: [RequestRetryCompletion] = []

    func should(
        _ manager: SessionManager,
        retry request: Request,
        with error: Error,
        completion: @escaping RequestRetryCompletion
    ) {
        lock.lock(); defer { lock.unlock() }

        let retry = {
            self.requestsToRetry.append(completion)
            self.retry(manager: manager)
        }

        if let error = error as? SpotifyApiError, error == .expiredToken {
            retry()
            return
        }

        if let response = request.task?.response as? HTTPURLResponse,
            response.statusCode == 401,
            request.retryCount == 0 {
            retry()
            return
        }

        completion(false, 0.0)
    }

    func retry(manager: SessionManager) {
        guard !isRefreshing else { return }

        isRefreshing = true

        GetToken(manager: manager).request { [weak self] result in
            guard let strongSelf = self else {
                return
            }

            guard let token = result.success as? SpotifyTokenAdapter else {
                print("token failed")
                strongSelf.requestsToRetry.forEach { $0(false, 0.0) }
                strongSelf.requestsToRetry.removeAll()

                return
            }

            print("returned valid token: \(token.accessToken)")

            SpotifyApiRouter.token = token
            manager.adapter = token
            SearchSpotify.spotifyManager.adapter = token
            strongSelf.requestsToRetry.forEach { $0(true, 0.0) }
            strongSelf.requestsToRetry.removeAll()

            strongSelf.isRefreshing = false
        }
    }
}
