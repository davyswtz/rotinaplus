import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                // Roxo primário — mesma cor de TelaBemVindo / LoginView
                .background(Color(red: 0.910, green: 0.471, blue: 0.188))
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

#Preview {
    PrimaryButton(title: "Entrar", action: {})
        .padding()
}
