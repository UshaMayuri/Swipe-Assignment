//
//  ProductView.swift
//  Swipe Assignment
//
//  Created by usha Mayuri on 19/07/24.
//

import SwiftUI

struct ProductView: View {
    
    @StateObject var vm = ProductViewModel.shared
    
    @State var showAddScreen: Bool = false
    @State private var search: String = ""
    
    private let fixedColumn = [
        GridItem(.fixed(180), spacing: 12),
        GridItem(.fixed(180), spacing: 12)
    ]
    
    var filteredProducts: [Response]? {
        if search == "" {
            return vm.modelData
        } else {
            return vm.modelData?.filter({ $0.productName.localizedCaseInsensitiveContains(search) })
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 20) {
                    SearchBox
                    if let allProduct = filteredProducts {
                        ScrollView(showsIndicators: false) {
                            LazyVGrid(columns: fixedColumn, spacing:10){
                                ForEach(allProduct) { product in
                                    productCardView(card: product)
                                }
                            }
                        }
                    } else {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                   
                }
                AddButton
            }
            .task {
                do {
                    try await vm.getDetails()
                } catch {
                    print(error)
                }
            }
            .sheet(isPresented: $showAddScreen) {
                AddProductView()
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    private func productCardView(card: Response) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            // For Image
            
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.purple.opacity(0.3))
                .frame(width: 160, height: 100)
                .overlay {
                    if card.image != "" {
                        if let imgURL = URL(string: card.image) {
                            AsyncImage(url: imgURL) { image in
                                image
                                    .resizable()
                                    .frame(width: 160, height: 100)
                                    .cornerRadius(18)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    } else {
                        Image(systemName: "photo.fill")
                    }
                }
                .padding([.top, .horizontal], 10)
            VStack {
                Text("\(card.productName)")
                    .font(.title2)
                    .fontDesign(.rounded)
                    .bold()
                
                Text(String(format: "₹ %.1f", card.price))
                    .bold()
                    .font(.body)
                    .fontDesign(.rounded)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            VStack(alignment: .leading) {
                Text("\(card.productType)")
                Text("Tax: \(String(format: "₹ %.1f", card.tax))")
                Spacer()
            }
            .font(.caption)
            .padding(.leading, 10)
            .padding(.top, 10)
        }
        .frame(width: 180,height: 230)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .stroke(.purple)
        }
    }
   
    private var SearchBox: some View {
        HStack() {
            TextField("Search", text: $search)
            .frame(maxWidth: .infinity, maxHeight: 50)
            .padding(.horizontal, 10)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.purple)
            }
            Button {
                
            } label: {
//                Image(systemName: "magnifyingglass.circle.fill")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 50,height: 50)
//                        .foregroundColor(.purple)
            }
        }
        .padding(.top, 10)
        .padding(.horizontal)
    }
    
    
    private var AddButton: some View {
        Button {
            showAddScreen.toggle()
        } label: {
            Image(systemName: "plus.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50,height: 50)
                    .foregroundColor(.purple)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .padding(.all)
    }
        
}

#Preview {
    ProductView()
}
