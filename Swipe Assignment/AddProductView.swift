//
//  AddProductView.swift
//  Swipe Assignment
//
//  Created by usha mayuri on 20/07/24.
//

import SwiftUI
import PhotosUI

struct AddProductView: View {
    
    @State var product: String = ""
    @State var price: String = ""
    @State var tax: String = ""
    @State var productType: String = ""
    
    @State var showPrompt: Bool = false
    @State var promptString: String = ""
    
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarImageData: Data?
    
    @StateObject var vm = ProductViewModel.shared
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack{
                    VStack(alignment: .leading,spacing: 17){
                        Text("Product")
                            .foregroundStyle(.black)
                            .font(.title3)
                            .fontWeight(.semibold)
                      
                        TextField("Product",text: $product)
                            .padding(.all)
                            .background {
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(.purple)
                                    .foregroundStyle(.clear)
                            }
                     
                        HStack {
                            Text("Product Type")
                                .foregroundStyle(.black)
                                .font(.title3)
                                .fontWeight(.semibold)
                            Spacer()
                            Picker("Choose Product Type", selection: $productType) {
                                ForEach(ProductType.allCases, id: \.self) { type in
                                    Text(type.description)
                                        .tag(type.description)
                                }
                            }
                            .tint(.purple)
                        }
                        
                        Text("Price")
                            .foregroundStyle(.black)
                            .font(.title3)
                            .fontWeight(.semibold)
                        TextField("Price", text: $price)
                            .padding(.all)
                            .background {
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(.purple)
                                    .foregroundStyle(.clear)
                            }
                            .keyboardType(.numberPad)
                        Text("Tax")
                            .foregroundStyle(.black)
                            .font(.title3)
                            .fontWeight(.semibold)
                        TextField("Tax", text: $tax)
                            .padding(.all)
                            .background {
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(.purple)
                                    .foregroundStyle(.clear)
                            }
                            .keyboardType(.numberPad)
                        HStack{
                            Text("Upload Image")
                                .foregroundStyle(.black)
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("(Optional)")
                        }
                       
                        PhotosPicker( selection: $avatarItem, matching: .images) {
                            HStack{
                                Text("Add Image")
                                    .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                                    
                                Image(systemName: "square.and.arrow.up.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width:30)
                            }
                            .frame(width: 380,height: 50)
                            .foregroundColor(.purple)
                            .opacity(0.7)
                                
                        }
                        .background{
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(.purple)
                                .foregroundStyle(.clear)
                        }
                        
                        if let avatarImageData, let uiImage = UIImage(data: avatarImageData) {
                            Image(uiImage: uiImage)
                               .resizable()
                               .scaledToFit()
                               .frame(width: 300, height: 300)
                        }
                                    
                        Spacer()
                        Button {
                            if (price.isEmpty || product.isEmpty || tax.isEmpty) { return }
                            let postProduct = PostProduct(image: avatarImageData, price: price, productName: product, productType: productType, tax: tax)
                            Task {
                                do {
                                    let success = try await vm.postDetails(product: postProduct)
                                    showPrompt.toggle()
                                    promptString = success ? "Product Added!" : "Failed"
                                } catch {
                                    showPrompt.toggle()
                                    promptString = error.localizedDescription
                                }
                            }
                        } label: {
                            RoundedRectangle(cornerRadius: 18)
                            .frame(width: 380,height: 50)
                            .foregroundColor(.purple)
                            .overlay(
                            Text("Add Product")
                                .foregroundColor(.white)
                            )
                        }
                        
                    }
                }
                .navigationTitle("Add Product")
                .padding(.all)
            }
            .alert(promptString, isPresented: $showPrompt) {
                Button("Okay", role: .cancel) {
                    Task {
                        try await vm.getDetails()
                    }
                    dismiss()
                }
            }
        }
        .onChange(of: avatarItem) {
            Task {
                do {
                    if let data = try await avatarItem?.loadTransferable(type: Data.self) {
                        avatarImageData = data
                    }
                } catch {
                    print(error.localizedDescription)
                    avatarItem = nil
                }
            }
        }
        
       
    }
}

#Preview {
    ProductView()
        .sheet(isPresented: .constant(true)) {
            AddProductView()
                .presentationDragIndicator(.visible)
        }
}
