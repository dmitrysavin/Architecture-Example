//
//  CategoriesViewController.swift
//  Evenz
//
//  Created by Dmitry Savin on 12/11/15.
//  Copyright © 2015 Engineering Idea. All rights reserved.
//

import UIKit
import Foundation
import AlamofireImage

/// Represents filters of events categories.
class CategoriesViewController: BaseViewController,
    SearchNavigationViewDelegate,
    DataSourceDelegate {
    
    /// Delegate of CategoriesViewController class.
    var delegate: CategoriesViewControllerDelegate?

    /// Property for events categories dataSource.
    var dataSource: EventsCategoriesDataSource
    
    /// Flow for all interactions with event categories screen.
    let updateEventCategoriesFlow: UpdateEventCategoriesFlow
    
    /// Identify that this screen was just loaded to perform necessary actions.
    /// It may be helpful in such methods like 'viewWillAppear(animated: Bool)'.
    var initialState = true
    
    /// Button to accept selected categories.
    @IBOutlet var goButton: UIButton!
    
    /// Collection view to represent categories.
    @IBOutlet var collectionView: UICollectionView!
    
    
    //MARK: - Interface -
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(dataSource: EventsCategoriesDataSource, updateEventCategoriesFlow: UpdateEventCategoriesFlow) {
        self.dataSource = dataSource
        self.updateEventCategoriesFlow = updateEventCategoriesFlow
        
        super.init(nibName: CategoriesViewController.className(), bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.addListener(self)
        dataSource.reloadData()
        
        registerObservers()
        setupCollectoinView()
        
        goButton.backgroundColor = ColorManager.buttonGreenColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if initialState {
            setupSearchFunctionality()
            initialState = false
        }
    }
    
    
    //MARK: - Privates -
    
    private func setupCollectoinView() {
        collectionView.registerNib(CategoryCell.nib(), forCellWithReuseIdentifier: CategoryCell.reuseIdentifier)
        adjustCollectionViewContentInsets()
    }

    private func adjustCollectionViewContentInsets() {
        collectionView.contentInset = UIEdgeInsetsMake(0.0, 0.0, SearchNavigationView.viewHeight(), 0.0)
        collectionView.scrollIndicatorInsets = collectionView.contentInset
    }
    
    private func setupSearchFunctionality() {
        let searchNavigationView = SearchNavigationView.view() as! SearchNavigationView
        searchNavigationView.setPlaceholderText("Input your text")
        searchNavigationView.frame = navigationController!.navigationBar.bounds
        searchNavigationView.delegate = self
        searchNavigationView.searchTextField.delegate = dataSource
        searchNavigationView.searchTextField.enablesReturnKeyAutomatically = false
        
        navigationController!.navigationBar.addSubview(searchNavigationView)
    }
    
    private func registerObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    @IBAction func goButtonSelected(sender: UIButton) {
        updateEventCategoriesFlow.save()
        delegate?.categoriesViewController(self, didSelectOkButton: sender)
        
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    //MARK: - Notifications -
    
    func keyboardWillShow(notification: NSNotification) {
        let keyboardRect = self.view.keyboardRect(notification)
        let animationDuration = self.view.keyboardAnimationDuration(notification)
        
        var insets = self.collectionView.contentInset;
        insets.bottom = keyboardRect.size.height
        
        UIView.animateWithDuration(NSTimeInterval(animationDuration)) { () -> Void in
            self.collectionView.contentInset = insets;
            self.collectionView.scrollIndicatorInsets = insets;
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let animationDuration = self.view.keyboardAnimationDuration(notification)
        
        UIView.animateWithDuration(NSTimeInterval(animationDuration)) { () -> Void in
            self.adjustCollectionViewContentInsets()
        }
    }
    
    
    //MARK: - Delegates -
    
    //MARK: SearchNavigationViewDelegate
    
    func searchNavigationView(searchNavigationView: SearchNavigationView, didSelectBackButton: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    //MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfItemsInSection(section)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let eventCategory = dataSource.itemAtIndexPath(indexPath) as! EventCategory
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CategoryCell.reuseIdentifier, forIndexPath: indexPath) as! CategoryCell
        cell.categoryLabel.text = eventCategory.shortName
        cell.categoryImageView.image = UIImage(named: "category_\(eventCategory.categoryId)")
        
        if let _ = self.updateEventCategoriesFlow.items.indexOf(eventCategory) {
            cell.backgroundImageView.image = UIImage(named: "categorySelectedBackground")
        } else {
            cell.backgroundImageView.image = UIImage(named: "categoryBackground")
        }

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let eventCategory = dataSource.itemAtIndexPath(indexPath) as! EventCategory
        
        if let index = self.updateEventCategoriesFlow.items.indexOf(eventCategory) {
            self.updateEventCategoriesFlow.items.removeAtIndex(index)
        } else {
            self.updateEventCategoriesFlow.items.append(eventCategory)
        }
        
        collectionView.reloadItemsAtIndexPaths([indexPath])
    }
    
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let itemsInRow  = 3
        let width = floor(CGRectGetWidth(view.frame) / CGFloat(itemsInRow))
        
        return CGSize(width: width, height: width)
    }
    
    
    //MARK: DataSourceDelegate
    
    func dataSourceWillLoadItems() {
    }
    
    func dataSourceDidLoadItems(items: AnyObject) {
        collectionView.reloadData()
    }
    
    func dataSourceDidLoadWithError(error: NSError) {
    }
}


/// Delegate of CategoriesViewController class.
protocol CategoriesViewControllerDelegate {
    func categoriesViewController(categoriesViewController: CategoriesViewController, didSelectOkButton: UIButton)
}
