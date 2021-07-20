//
//  CurExCurExView.swift
//  CurEx
//
//  Created by Artem Shcherbakov on 16/07/2021.
//  Copyright © 2021 BLANC. All rights reserved.
//

import UIKit

class CurExView: UIViewController {

    private var dataSource: CurExPresenterDataSource?
    
    // Элементы представления
    var background = UIImageView(frame: .zero)
    var currencyBlock = UIView()
    var arrow = UIImageView()
    var currencyBlock2 = UIView()

    override func loadView() {
        view = UIView()
        
        // Отлавливаем переход в фоновый режим
        let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        // Закрываем клавиатуру
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
        
        // Заполняем navigation bar
        navigationItem.title = "Currency"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Exchange", style: .plain, target: self, action: #selector(exchangePressed))
        
        // Заполняем элементы представления, применяем к ним модификаторы
        fillBackground()
        fillCurrencyBlock(labelText: "USD", value: "", walletText: "You have: 100.0$", rateText: "1.0$ = 1.0$", editable: true, field: true)
        fillArrow()
        fillCurrencyBlock(labelText: "USD", value: "", walletText: "You have: 100.0$", rateText: "1.0$ = 1.0$", editable: false, field: true)

        // Добавляем элементы представления в родительский view
        view.addSubview(background)
        view.addSubview(self.currencyBlock)
        view.addSubview(self.arrow)
        view.addSubview(self.currencyBlock2)
        
        // Активируем константы с якорями
        activateBackgroundConstraints()
        activateCurrencyBlocksConstraints()
        activateArrowConstraints()
        activateCurrencyBlocksSubviewsConstraints()
        
    }
    
    func fillBackground() {
        background.image = UIImage(named: "curexbg")
        background.contentMode = .scaleToFill
        background.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func fillArrow() {
        arrow.image = UIImage(named: "arrow.down")
        arrow.translatesAutoresizingMaskIntoConstraints = false
        arrow.tintColor = .white
    }
    
    func fillCurrencyBlock(labelText: String, value: String, walletText: String, rateText: String, editable: Bool, field: Bool) {
        let block = editable ? self.currencyBlock : self.currencyBlock2

        // Дочерние элементы блока валюты
        let currencyLabel = UILabel()
        let exValue = UITextField()
        let wallet = UILabel()
        let exRate = UILabel()
        
        // Применяем модификаторы к дочерним элементам
        currencyLabel.translatesAutoresizingMaskIntoConstraints = false
        currencyLabel.text = labelText
        currencyLabel.textColor = .black
        currencyLabel.font = UIFont.systemFont(ofSize: 48)
        block.insertSubview(currencyLabel, at: 0)
        
        if field {
            exValue.text = value
            exValue.translatesAutoresizingMaskIntoConstraints = false
            exValue.textColor = editable ? .systemRed : .systemGreen
            exValue.font = UIFont.systemFont(ofSize: 48)
            exValue.keyboardType = UIKeyboardType.decimalPad
            exValue.attributedPlaceholder = NSAttributedString(string: "0.00", attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkGray])
            exValue.textAlignment = .right
            exValue.isUserInteractionEnabled = editable ? true : false
            exValue.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
            block.addSubview(exValue)
        }
        
        wallet.translatesAutoresizingMaskIntoConstraints = false
        wallet.text = walletText
        wallet.textColor = .black
        wallet.font = UIFont.systemFont(ofSize: 18)
        block.addSubview(wallet)
        
        exRate.translatesAutoresizingMaskIntoConstraints = false
        exRate.text = rateText
        exRate.textColor = .black
        exRate.font = UIFont.systemFont(ofSize: 18)
        block.addSubview(exRate)
        
        // Применяем модификаторы к родительскому элементу
        block.translatesAutoresizingMaskIntoConstraints = false
        block.backgroundColor = .white
        block.layer.masksToBounds = true
        block.layer.cornerRadius = 25
        block.tag = editable ? 1 : 2
        
        // Устанавливаем распознаватели свайпов
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        block.addGestureRecognizer(leftSwipe)
        block.addGestureRecognizer(rightSwipe)
    }
    
    func activateBackgroundConstraints() {
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: view.topAnchor),
            background.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            background.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func activateArrowConstraints() {
        NSLayoutConstraint.activate([
            arrow.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            arrow.topAnchor.constraint(equalTo: currencyBlock.bottomAnchor, constant: 20),
            arrow.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.1),
            arrow.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.1)
        ])
    }
    
    func activateCurrencyBlocksConstraints() {
        NSLayoutConstraint.activate([
            currencyBlock.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            currencyBlock.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            currencyBlock.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9),
            currencyBlock.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.2),
            
            currencyBlock2.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            currencyBlock2.topAnchor.constraint(equalTo: arrow.bottomAnchor, constant: 20),
            currencyBlock2.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9),
            currencyBlock2.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.2),
        ])
    }
    
    func activateCurrencyBlocksSubviewsConstraints() {
        NSLayoutConstraint.activate([
            currencyBlock.subviews[0].topAnchor.constraint(equalTo: currencyBlock.topAnchor, constant: 5),
            currencyBlock.subviews[0].leadingAnchor.constraint(equalTo: currencyBlock.leadingAnchor, constant: 10),
            currencyBlock.subviews[1].topAnchor.constraint(equalTo: currencyBlock.topAnchor, constant: 4),
            currencyBlock.subviews[1].trailingAnchor.constraint(equalTo: currencyBlock.trailingAnchor, constant: -10),
            currencyBlock.subviews[2].bottomAnchor.constraint(equalTo: currencyBlock.bottomAnchor, constant: -15),
            currencyBlock.subviews[2].leadingAnchor.constraint(equalTo: currencyBlock.leadingAnchor, constant: 10),
            currencyBlock.subviews[3].bottomAnchor.constraint(equalTo: currencyBlock.bottomAnchor, constant: -15),
            currencyBlock.subviews[3].trailingAnchor.constraint(equalTo: currencyBlock.trailingAnchor, constant: -10),
            
            currencyBlock2.subviews[0].topAnchor.constraint(equalTo: currencyBlock2.topAnchor, constant: 5),
            currencyBlock2.subviews[0].leadingAnchor.constraint(equalTo: currencyBlock2.leadingAnchor, constant: 10),
            currencyBlock2.subviews[1].topAnchor.constraint(equalTo: currencyBlock2.topAnchor, constant: 4),
            currencyBlock2.subviews[1].trailingAnchor.constraint(equalTo: currencyBlock2.trailingAnchor, constant: -10),
            currencyBlock2.subviews[2].bottomAnchor.constraint(equalTo: currencyBlock2.bottomAnchor, constant: -15),
            currencyBlock2.subviews[2].leadingAnchor.constraint(equalTo: currencyBlock2.leadingAnchor, constant: 10),
            currencyBlock2.subviews[3].bottomAnchor.constraint(equalTo: currencyBlock2.bottomAnchor, constant: -15),
            currencyBlock2.subviews[3].trailingAnchor.constraint(equalTo: currencyBlock2.trailingAnchor, constant: -10)
        ])
    }
    
    func cleanCurrencyBlocks(saveField: Bool) {
        self.currencyBlock.subviews[3].removeFromSuperview()
        self.currencyBlock.subviews[2].removeFromSuperview()
        if !saveField { self.currencyBlock.subviews[1].removeFromSuperview() }
        self.currencyBlock.subviews[0].removeFromSuperview()
        self.currencyBlock2.subviews[3].removeFromSuperview()
        self.currencyBlock2.subviews[2].removeFromSuperview()
        self.currencyBlock2.subviews[1].removeFromSuperview()
        self.currencyBlock2.subviews[0].removeFromSuperview()
    }
    

    
    func refresh(viewModel: CurExViewModel, saveField: Bool) {
        // Перезаполняем блоки валюты
        self.cleanCurrencyBlocks(saveField: saveField)
        self.fillCurrencyBlock(labelText: viewModel.upperCurrency, value: viewModel.upperValue, walletText: viewModel.upperWallet, rateText: viewModel.upperRate, editable: true, field: !saveField)
        self.fillCurrencyBlock(labelText: viewModel.lowerCurrency, value: viewModel.lowerValue, walletText: viewModel.lowerWallet, rateText: viewModel.lowerRate, editable: false, field: true)
        self.activateCurrencyBlocksSubviewsConstraints()
    }
    
    func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func swipe(_ sender: UISwipeGestureRecognizer) {
        let block = sender.view!
        if sender.direction == .left {
            // Анимация исчезновения влево
            UIView.animateKeyframes(withDuration: 1, delay: 0, options: .calculationModeLinear, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                    block.center = CGPoint(x: self.view.center.x, y: block.center.y)
                }
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                    block.center = CGPoint(x: 0, y: block.center.y)
                    block.alpha = 0.0
                }
            })
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
                // Передаем свайп презентеру для обработки
                self.dataSource?.swipe(direction: "left", block: block.tag)
                // Анимация появления справа
                UIView.animateKeyframes(withDuration: 1, delay: 0, options: .calculationModeLinear, animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0) {
                        block.center = CGPoint(x: self.view.bounds.width, y: block.center.y)
                        block.alpha = 0.0
                    }
                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                        block.center = CGPoint(x: self.view.center.x, y: block.center.y)
                        block.alpha = 1
                    }
                })
            }
        }
        if sender.direction == .right {
            // Анимация исчезновения вправо
            UIView.animateKeyframes(withDuration: 1, delay: 0, options: .calculationModeLinear, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                    block.center = CGPoint(x: self.view.center.x, y: block.center.y)
                }
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                    block.center = CGPoint(x: self.view.bounds.width, y: block.center.y)
                    block.alpha = 0.0
                }
            })
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
                // Передаем свайп презентеру для обработки
                self.dataSource?.swipe(direction: "right", block: block.tag)
                // Анимация появления слева
                UIView.animateKeyframes(withDuration: 1, delay: 0, options: .calculationModeLinear, animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0) {
                        block.center = CGPoint(x: 0, y: block.center.y)
                        block.alpha = 0.0
                    }
                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                        block.center = CGPoint(x: self.view.center.x, y: block.center.y)
                        block.alpha = 1
                    }
                })
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        // Передаем содержимое поля ввода презентеру для обработки
        self.dataSource?.fieldChanged(value: textField.text!)
    }
    
    @objc func exchangePressed() {
        // Сообщаем презентеру о нажатии на кнопку обмена валюты
        self.dataSource?.exchangePressed()
    }
    
    @objc func appMovedToBackground() {
        // Сообщаем презентеру, что приложение перешло в фоновый режим
        self.dataSource?.saveWalletsToUserDefaults()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = CurExConfigurator().getDataSource()
        self.dataSource?.fetch(objectFor: self)
        // Обновляем курсы валют каждые 30 секунд
        /*Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { timer in
            self.dataSource?.fetch(objectFor: self)
        }*/
    }

    deinit {
        print("deinit view")
    }
}

extension CurExView: CurExViewViewer {
    func response(_ viewModel: CurExViewModel) {
        // Обрабатывем ответы от презентера
        DispatchQueue.main.async {
            switch viewModel.event {
                case "next" : print("Следующая валюта активирована")
                    self.refresh(viewModel: viewModel, saveField: true)
                    
                case "previous" : print("Предыдущая валюта активирована")
                    self.refresh(viewModel: viewModel, saveField: true)
                    
                case "value" : print("Введены данные в поле ввода")
                    self.refresh(viewModel: viewModel, saveField: true)
                    // Следующие 2 строки нужны для принудительного обновления поля ввода после форматирования его значения
                    let field = self.currencyBlock.subviews[1] as! UITextField
                    field.text = viewModel.upperValue
                    
                case "update" : print("Курсы валют обновлены")
                    self.refresh(viewModel: viewModel, saveField: true)
                    self.navigationItem.title = "-= Updated =-"
                    Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { timer in
                        self.navigationItem.title = "Currency"
                    }
                case "exchange" : print("Обмен валюты завершен")
                    self.showAlert("Успешно!", "Списано: \(viewModel.credited) \(viewModel.upperCurrency)\nЗачислено: \(viewModel.debited) \(viewModel.lowerCurrency)")
                    self.refresh(viewModel: viewModel, saveField: false)
                    
                case "nomoney" : print("Недостаточно средств для обмена")
                    self.showAlert("Упс!", "У вас недостаточно \(viewModel.upperCurrency) для этого обмена")
                    
                case "emptyfield" : print("Поле ввода пустое или содержит некорректное значение")
                    self.showAlert("Вы на пути к цели", "Введите сумму для конвертации")
                    
                case "background" : print("Перешли в фоновый режим")
                    
                case "disconnected" : print("Нет соединения с интернетом")
                    self.showAlert("Соединение отсутствует", "Подключитесь к интернету для продолжения работы")
                    
                default : print("Неизвестное событие")
            }
        }
    }

    func response(_ error: NSError) {
        print(error.userInfo["reason"] ?? "")
    }
}
