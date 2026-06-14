import mongoose from "mongoose";

async function connectDB() {
    try {
        const mongoUri = process.env.MONGO_URI;

        if (!mongoUri) {
            throw new Error("Veuillez fournir une URI MONGO_URI dans le fichier .env");
        }
        const conn = await mongoose.connect(mongoUri);
        console.log("MongoDB connected", conn.connection.host);
    } catch (error) {
        console.error("Erreur de connexion à MongoDB:", error.message);
        process.exit(1);
    }
}

export default connectDB;