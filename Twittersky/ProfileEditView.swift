//
//  ProfileEditView.swift
//  Twittersky
//
//  Created by Eduard Dzhumagaliev on 31.01.2021.
//

import SwiftUI

protocol ProfileEditViewDelegate {
    func cancelEdit()
    func saveChanges()
    func logout()
    func destroy()
}

struct ProfileEditView: View {
    @State var user: User
    @State var fullName: String
    @State var biography: String
    @State var city: City?
    @State var avatar: String
    var delegate: ProfileEditViewDelegate?

    init() {
        let user = User(context: NSManagedObjectContext.shared)
        user.fullName = "Eduard Dzhumagaliev"
        user.biography = "20yr old iOS Developer"
        user.city = City(context: NSManagedObjectContext.shared)
        user.city?.name = "Vladivostok"
        user.city?.country = "Russia"
        user.avatarUrl = ""
        _user = State(initialValue: user)
        _fullName = State(initialValue: user.fullName ?? "")
        _biography = State(initialValue: user.biography ?? "")
        _city = State(initialValue: user.city)
        _avatar = State(initialValue: user.avatarUrl ?? "")
    }
    
    init(with user: User, delegate: ProfileEditViewDelegate? = nil) {
        _user = State(initialValue: user)
        _fullName = State(initialValue: user.fullName ?? "")
        _biography = State(initialValue: user.biography ?? "")
        _city = State(initialValue: user.city)
        _avatar = State(initialValue: user.avatarUrl ?? "")
        self.delegate = delegate
    }
    
    let cities: [City] = {
        let request: NSFetchRequest<City> = City.fetchRequest()
        if let response = try? NSManagedObjectContext.shared.fetch(request) {
            for city in response {
                print(city)
            }
            return response
        }
        
        return [City]()
    }()
    
    func changeAvatar() {
        let fileDialog = NSOpenPanel()
        fileDialog.prompt = "Choose avatar"
        fileDialog.worksWhenModal = true
        fileDialog.canChooseDirectories = true
        fileDialog.canChooseFiles = true
        fileDialog.allowedFileTypes = ["png", "jpg", "jpeg"]
        fileDialog.begin { (result) in
            if result == .OK {
                let selectedPath = fileDialog.url!.path
                let image = NSImage(byReferencingFile: selectedPath)
                let documentsDirectoryUrl = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let fileURL = documentsDirectoryUrl.appendingPathComponent("\(image.hashValue).png")
                
                if !FileManager.default.fileExists(atPath: fileURL.path) {
                    let representation = image!.tiffRepresentation!
                    let data = NSBitmapImageRep(data: representation)
                    try! data?.representation(using: .png, properties: [:])?.write(to: fileURL)
                }
                
                avatar = fileURL.path
                user.avatarUrl = fileURL.path
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Button(action: {
                    changeAvatar()
                }, label: {
                    if avatar.count > 0, let nsImage = NSImage(contentsOfFile: avatar) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 64, height: 64, alignment: .center)
                            .scaledToFit()
                            .background(Color.primary)
                            .clipShape(Circle())
                    } else {
                        Circle().frame(width: 64, height: 64, alignment: .center)
                    }
                    
                }).buttonStyle(PlainButtonStyle())
                VStack(alignment: .leading) {
                    HStack {
                        Text("Display name: ").bold()
                        Spacer()
                        Text("\(50 - fullName.count) characters left").foregroundColor({
                            if (50 - fullName.count < 0) {
                                return Color.red
                            } else {
                                return Color.primary
                            }
                        }())
                    }
                    TextField("Display name", text: $fullName)
                    HStack {
                        Text("Biography: ").bold()
                        Spacer()
                        Text("\(255 - biography.count) characters left").foregroundColor({
                            if (255 - biography.count) < 0 {
                                return Color.red
                            } else {
                                return Color.white
                            }
                        }())
                    }
                    TextEditor(text: $biography).foregroundColor(Color.primary).border(SeparatorShapeStyle(), width: 1)
    //            Picker(selection: /*@START_MENU_TOKEN@*/.constant(1)/*@END_MENU_TOKEN@*/, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/, content: {
    //                ForEach(, content: <#T##(_.Element) -> _#>)
    //            })
                    Picker(selection: $city, label: Text("City: "), content: {
                        Text("Choose city").tag(City?.none)
                        ForEach(cities) { (city: City) in
                            Text("\(city.name ?? ""), \(city.country ?? "")").tag(City?.some(city))
                        }
                    }).pickerStyle(MenuPickerStyle())
                }
            }
            Spacer()
            HStack {
                Button("Logout", action: {delegate?.logout()})
                Button("Destroy profile", action: {delegate?.destroy()})
                Button("Cancel", action: {delegate?.cancelEdit()}).keyboardShortcut(.cancelAction)
                Button("Save", action: {saveChanges(); delegate?.saveChanges()}).keyboardShortcut(.return).disabled({
                    if (255 - biography.count) < 0 {
                        return true
                    }
                    if (50 - fullName.count) < 0 {
                        return true
                    }
                    return false
                }())
            }
        }
        .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
    }
    
    func saveChanges() {
        self.user.fullName = fullName
        self.user.biography = biography
        print(self.user.city, city)
        self.user.city = city
        self.user.avatarUrl = avatar
        NSManagedObjectContext.saveShared()
    }
}

struct ProfileEditView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileEditView()
    }
}
