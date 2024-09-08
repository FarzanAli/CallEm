import SwiftUI

class MenuOption: Identifiable {
    let id = UUID()
    let title: String
    let digit: String
    var children: [MenuOption]
    
    init(title: String, digit: String, children: [MenuOption] = []) {
        self.title = title
        self.digit = digit
        self.children = children
    }
}

class MenuViewModel: ObservableObject {
    @Published var currentOptions: [MenuOption]
    private var history: [[MenuOption]] = []
    private var forwardHistory: [[MenuOption]] = []
    
    init(rootOptions: [MenuOption]) {
        self.currentOptions = rootOptions
    }
    
    func selectOption(_ option: MenuOption) {
        if !option.children.isEmpty {
            history.append(currentOptions)
            currentOptions = option.children
            forwardHistory.removeAll()
        }
    }
    
    func goBack() {
        if let previousOptions = history.popLast() {
            forwardHistory.append(currentOptions)
            currentOptions = previousOptions
        }
    }
    
    func goForward() {
        if let nextOptions = forwardHistory.popLast() {
            history.append(currentOptions)
            currentOptions = nextOptions
        }
    }
    
    var canGoBack: Bool {
        return !history.isEmpty
    }
    
    var canGoForward: Bool {
        return !forwardHistory.isEmpty
    }
}

struct MenuView: View {
    @StateObject private var viewModel: MenuViewModel
    let callManager: CallManager
    
    init(rootOptions: [MenuOption], callManager: CallManager) {
        _viewModel = StateObject(wrappedValue: MenuViewModel(rootOptions: rootOptions))
        self.callManager = callManager
    }
    
    var body: some View {
        VStack {
            ForEach(viewModel.currentOptions) { option in
                Button(action: {
                    callManager.sendDigit(digit: option.digit)
                    viewModel.selectOption(option)
                }) {
                    Text(option.title)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
                .padding(.vertical, 2)
            }
            
            Spacer()
            
            HStack {
                Button("Previous") {
                    viewModel.goBack()
                }
                .disabled(!viewModel.canGoBack)
                
                Spacer()
                
                Button("Next") {
                    viewModel.goForward()
                }
                .disabled(!viewModel.canGoForward)
            }
            .padding()
        }
        //        .navigationBarTitle("Menu Options", displayMode: .inline)
        .padding()
    }
}
let menuTree: MenuOption = {
    return MenuOption(
        title: "Welcome to Rogers. For English, press 1. Pour le français, faites le 2.",
        digit: "",
        children: [
            MenuOption(
                title: "For English, press 1.",
                digit: "1",
                children: [
                    MenuOption(
                        title: "Please enter your phone number, then press pound.",
                        digit: "#"
                    ),
                    MenuOption(
                        title: "If new to Rogers, press star.",
                        digit: "*",
                        children: [
                            MenuOption(
                                title: "For billing and payment inquiries, press 1.",
                                digit: "1",
                                children: [
                                    MenuOption(
                                        title: "For your account balance, press 1.",
                                        digit: "1",
                                        children: [
                                            MenuOption(
                                                title: "To better assist you, please enter your 10-digit telephone number, including the area code, then press pound.",
                                                digit: "#"
                                            )
                                        ]
                                    ),
                                    MenuOption(
                                        title: "To make a payment, press 2.",
                                        digit: "2",
                                        children: [
                                            MenuOption(
                                                title: "To better assist you, please enter your 10-digit telephone number, including the area code, then press pound.",
                                                digit: "#"
                                            )
                                        ]
                                    ),
                                    MenuOption(title: "For payment arrangements, press 3.", digit: "3"),
                                    MenuOption(title: "For usage details, press 4.", digit: "4"),
                                    MenuOption(title: "For more options, press 5.", digit: "5")
                                ]
                            ),
                            MenuOption(
                                title: "For technical support, press 2.",
                                digit: "2",
                                children: [
                                    MenuOption(
                                        title: "To better assist you, please enter your 10-digit telephone number, including the area code, then press pound.",
                                        digit: "#"
                                    )
                                ]
                            ),
                            MenuOption(
                                title: "To add products and services, press 3.",
                                digit: "3",
                                children: [
                                    MenuOption(
                                        title: "For all your mobile needs, including 5G home Internet, press 1.",
                                        digit: "1",
                                        children: [
                                            MenuOption(
                                                title: "If you're already a Rogers mobile or 5G home Internet customer, press 1.",
                                                digit: "1"
                                            ),
                                            MenuOption(
                                                title: "If you would like to become a new mobile or 5G home Internet customer, press 2.",
                                                digit: "2"
                                            ),
                                            MenuOption(
                                                title: "For phone number transfer requests to Rogers, press 3.",
                                                digit: "3"
                                            )
                                        ]
                                    ),
                                    MenuOption(
                                        title: "For all your residential needs, press 2.",
                                        digit: "2"
                                    )
                                ]
                            ),
                            MenuOption(
                                title: "For account changes, press 4.",
                                digit: "4",
                                children: [
                                    MenuOption(
                                        title: "For travel-related inquiries, including roaming, press 1.",
                                        digit: "1"
                                    ),
                                    MenuOption(
                                        title: "To report a lost or stolen device, press 2.",
                                        digit: "2"
                                    ),
                                    MenuOption(
                                        title: "For move-related inquiries, press 3.",
                                        digit: "3"
                                    ),
                                    MenuOption(
                                        title: "To change a service, press 4.",
                                        digit: "4"
                                    ),
                                    MenuOption(
                                        title: "To cancel a service, press 5.",
                                        digit: "5"
                                    ),
                                    MenuOption(
                                        title: "To hear more options, press 6.",
                                        digit: "6",
                                        children: [
                                            MenuOption(
                                                title: "Most account modifications such as price plan changes or modifying your contact information can be done through Rogers.com. To do so now, hang up and visit www.rogers.com.",
                                                digit: ""
                                            ),
                                            MenuOption(
                                                title: "To schedule or modify a temporary suspension of your mobile phone, press 1.",
                                                digit: "1"
                                            ),
                                            MenuOption(
                                                title: "To update or change your method of payment, press 2.",
                                                digit: "2"
                                            ),
                                            MenuOption(
                                                title: "To create or reset your account PIN, press 3.",
                                                digit: "3"
                                            ),
                                            MenuOption(
                                                title: "To purchase new products or services, press 4.",
                                                digit: "4"
                                            ),
                                            MenuOption(
                                                title: "To update or change your contact number, email address, or billing address, press 5.",
                                                digit: "5"
                                            ),
                                            MenuOption(
                                                title: "For all other account changes, press 6.",
                                                digit: "6"
                                            ),
                                            MenuOption(
                                                title: "For more information, visit www.rogers.com.",
                                                digit: ""
                                            )
                                        ]
                                    )
                                ]
                                
                            )
                        ]
                    )
                ]
            ),
            MenuOption(
                title: "Pour le français, faites le 2.",
                digit: "2"
            )
        ]
    )
}()


// Define the tree structure with digit attributes
//let menuTree = MenuOption(title: "Root", digit: "", children: [
//    MenuOption(title: "Press 1 for English", digit: "1", children: [
//        MenuOption(title: "Press 1 for Billing", digit: "1", children: [
//            MenuOption(title: "Press 1 for Account Balance", digit: "1"),
//            MenuOption(title: "Press 2 for Payment History", digit: "2")
//        ]),
//        MenuOption(title: "Press 2 for Support", digit: "2", children: [
//            MenuOption(title: "Press 1 for Technical Support", digit: "1"),
//            MenuOption(title: "Press 2 for Customer Service", digit: "2")
//        ]),
//        MenuOption(title: "Press 3 for Sales", digit: "3", children: [
//            MenuOption(title: "Press 1 for New Products", digit: "1"),
//            MenuOption(title: "Press 2 for Promotions", digit: "2")
//        ])
//    ]),
//    MenuOption(title: "Press 2 for French", digit: "2", children: [
//        MenuOption(title: "Appuyez sur 1 pour la facturation", digit: "1", children: [
//            MenuOption(title: "Appuyez sur 1 pour le solde du compte", digit: "1"),
//            MenuOption(title: "Appuyez sur 2 pour l'historique des paiements", digit: "2")
//        ]),
//        MenuOption(title: "Appuyez sur 2 pour le support", digit: "2", children: [
//            MenuOption(title: "Appuyez sur 1 pour le support technique", digit: "1"),
//            MenuOption(title: "Appuyez sur 2 pour le service client", digit: "2")
//        ]),
//        MenuOption(title: "Appuyez sur 3 pour les ventes", digit: "3", children: [
//            MenuOption(title: "Appuyez sur 1 pour les nouveaux produits", digit: "1"),
//            MenuOption(title: "Appuyez sur 2 pour les promotions", digit: "2")
//        ])
//    ])
//])

// Example usage
//struct ContentView: View {
//    var body: some View {
//
//    }
//}

//@main
//struct TreeMenuApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
