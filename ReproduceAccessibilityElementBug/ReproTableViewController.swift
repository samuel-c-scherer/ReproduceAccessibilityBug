import UIKit

class ReproTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(ReproTableCell.nib,
                           forCellReuseIdentifier: ReproTableCell.defaultReuseIdentifier)
    }
}

public extension UITableView {

    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(
            withIdentifier: T.defaultReuseIdentifier,
            for: indexPath
        ) as? T else {
            fatalError("Unable to Dequeue Reusable Table View Cell")
        }

        return cell
    }
}

@objc extension UITableViewCell {
    struct Constants {
        static let indentMaxLeadingSpace: CGFloat = 14
        static let indentMinLeadingSpace: CGFloat = 0
    }

    @objc class var defaultReuseIdentifier: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }

    static var nib: UINib {
        return UINib(nibName: defaultReuseIdentifier, bundle: nil)
    }
}

// MARK: - Table view data source and delegate

extension ReproTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let timersPreviewCell: ReproTableCell = tableView.dequeueReusableCell(withIdentifier: "ReproTableCell", for: indexPath) as! ReproTableCell

        timersPreviewCell.configure()
        return timersPreviewCell
    }
}

class ReproTableCell: UITableViewCell {
    @IBOutlet private var timersPreview: ReproPreview!

    func configure() {
        timersPreview.configure()
        timersPreview.heightAnchor.constraint(equalToConstant: 300).isActive = true
        timersPreview.isAccessibilityElement = false
        self.isAccessibilityElement = false
    }
}

class ReproPreview: UIView,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    UIScrollViewDelegate {
    
    private enum Constants {
        static let itemHeight: CGFloat = 150
        static let cellReuseIdentifier = "ReproCollectionCell"
    }
    
    private var testTitles = ["Title 1", "Title 2"]

    @IBOutlet private var contentView: UIView!
    @IBOutlet private var pageControl: UIPageControl!
    @IBOutlet private var collectionView: UICollectionView!


    override init(frame: CGRect) {
        super.init(frame: frame)
        createUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createUI()
    }

    func configure() {
        pageControl.numberOfPages = testTitles.count
        collectionView.reloadData()
    }

    //  MARK: UIPageControl Action

    @IBAction private func pageControlAction(_ sender: UIPageControl) {
        collectionView.scrollToItem(
            at: IndexPath(
                item: sender.currentPage,
                section: 0
            ),
            at: .centeredHorizontally,
            animated: true
        )
    }
}

extension ReproPreview {
    //  MARK: UICollectionViewDataSource, UICollectionViewDelegate

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        pageControl.numberOfPages
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Constants.cellReuseIdentifier,
            for: indexPath
        ) as! ReproCollectionCell

        cell.configure(
            with: testTitles[indexPath.item]
        )
        return cell
    }

    //  MARK: UICollectionViewDelegateFlowLayout

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(
            width: bounds.width,
            height: Constants.itemHeight
        )
    }

    // MARK: - UIScrollViewDelegate

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        pageControl.currentPage = Int(
            targetContentOffset.pointee.x / bounds.width
        )
        if let timerCollectionCell = collectionView.cellForItem(at: IndexPath(row: pageControl.currentPage, section: 0)) as? ReproCollectionCell {
            timerCollectionCell.postPageScrolled()
        }
    }
}

private extension ReproPreview {
    func createUI() {
        Bundle.main.loadNibNamed(
            "ReproPreview",
            owner: self,
            options: nil
        )
        contentView.autoresizingMask = [.flexibleWidth,
                                        .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)

        setupCollectionView()
    }

    func setupCollectionView() {
        // Register Collection Cell
        let nib = UINib(
            nibName: String(
                describing: ReproCollectionCell.self
            ),
            bundle: Bundle(for: ReproCollectionCell.self)
        )
        collectionView.register(
            nib,
            forCellWithReuseIdentifier: Constants.cellReuseIdentifier
        )
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
    }
}

import UIKit

class ReproCollectionCell: UICollectionViewCell {
    @IBOutlet private var headerTitle: UILabel!

    func configure(with title: String) {
        headerTitle.text = title
        headerTitle.accessibilityValue = headerTitle.text
        headerTitle.accessibilityIdentifier = headerTitle.text
        headerTitle.accessibilityLabel = headerTitle.text
    }

    func postPageScrolled() {
        headerTitle.accessibilityValue = headerTitle.text
        DispatchQueue.main.async {
            UIAccessibility.post(notification: .pageScrolled, argument: nil)
        }
    }
}
