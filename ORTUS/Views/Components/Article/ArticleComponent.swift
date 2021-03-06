//
//  ArticleComponent.swift
//  ORTUS
//
//  Created by Firdavs Khaydarov on 21/03/19.
//  Copyright © 2019 Firdavs. All rights reserved.
//

import UIKit
import Carbon
import Kingfisher

struct ArticleComponent: IdentifiableComponent {
    var id: String
    var article: Article
    var onSelect: (() -> Void)?
    
    func renderContent() -> ArticleComponentView {
        return ArticleComponentView()
    }
    
    func render(in content: ArticleComponentView) {
        content.onSelect = onSelect
        
        if let imageURL = article.imageURL {
            content.imageView.kf.setImage(with: URL(string: imageURL))
        }
        
        content.authorLabel.text = article.author
        content.titleLabel.text = article.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        content.dateLabel.text = dateFormatter.string(from: article.date)
    }
    
    func referenceSize(in bounds: CGRect) -> CGSize? {
        return nil
    }
    
    func shouldContentUpdate(with next: ArticleComponent) -> Bool {
        return article.id != next.article.id
    }
}

