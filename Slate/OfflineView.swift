import UIKit

/// Shown when the board can't be reached: a plain message and Try again, in the board's colors.
final class OfflineView: UIView {
    var onRetry: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Board.navy

        let title = UILabel()
        title.text = "Can't reach the board"
        title.font = .systemFont(ofSize: 20, weight: .bold)
        title.textColor = Board.chalk

        let note = UILabel()
        note.text = "Check your connection and try again."
        note.font = .systemFont(ofSize: 15)
        note.textColor = Board.muted
        note.numberOfLines = 0
        note.textAlignment = .center

        var look = UIButton.Configuration.filled()
        look.title = "Try again"
        look.baseBackgroundColor = Board.gold
        look.baseForegroundColor = Board.goldInk
        look.cornerStyle = .capsule
        look.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 22, bottom: 10, trailing: 22)
        let button = UIButton(configuration: look, primaryAction: UIAction { [weak self] _ in self?.onRetry?() })

        let stack = UIStackView(arrangedSubviews: [title, note, button])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 10
        stack.setCustomSpacing(22, after: note)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -32),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not used")
    }
}
