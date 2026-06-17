import express from "express";
import "dotenv/config"
import connectDB from "./lib/db.js";
import User from "./models/user.model.js";
import { clerkMiddleware } from '@clerk/express'
import cors from 'cors';
import path from 'path';
import fs from "fs"
import job from "./lib/cron.js";

const app = express();
const PORT = process.env.PORT;
const FRONTEND_URL = process.env.FRONTEND_URL;

const publicDir = path.join(process.cwd(), 'public');

app.use(cors({ origin: FRONTEND_URL, credentials: true }));
app.use(express.json());
app.use(clerkMiddleware());

app.get("/health", (req, res) => {
    res.status(200).json({ ok: true });
});

app.use(express.static(publicDir));

app.get("/{*any}", (req, res, next) => {
    res.sendFile(path.join(publicDir, 'index.html'), (err) => {
        if (err) next(err);
    });
});


app.listen(PORT, () => {
    connectDB();
    console.log(`Serveur lancé sur le port ${PORT}`)
    if (process.env.NODE_ENV === "production") job.start()
})