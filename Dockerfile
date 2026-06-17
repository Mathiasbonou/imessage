# Monolithe : frontend Vite + API Express. Build depuis la racine du repo.

# --- Étape 1 : build du SPA (Vite) ---
# Produit du HTML/JS/CSS statique dans frontend/dist.
FROM node:22-bookworm-slim AS frontend-build
WORKDIR /app/frontend
COPY frontend/package.json frontend/package-lock.json ./
RUN npm install --no-audit --no-fund --legacy-peer-deps
COPY frontend/ ./
# Vide = le navigateur appelle /api sur le même hôte que la page.
ENV VITE_API_URL=
# La clé publique Clerk est intégrée dans le JS client.
ARG VITE_CLERK_PUBLISHABLE_KEY
ENV VITE_CLERK_PUBLISHABLE_KEY=$VITE_CLERK_PUBLISHABLE_KEY
RUN npm run build

# --- Étape 2 : build du bundle de l'API ---
# Ce backend est en JavaScript ESM, donc npm run build copie src/ vers dist/.
FROM node:22-bookworm-slim AS backend-build
WORKDIR /app
COPY backend/package.json backend/package-lock.json ./
RUN npm install --no-audit --no-fund
COPY backend/ ./
RUN npm run build

# --- Étape 3 : image d'exécution (uniquement les deps de prod + fichiers buildés) ---
# Express sert les routes API et les fichiers statiques depuis public/.
FROM node:22-bookworm-slim AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3001

COPY backend/package.json backend/package-lock.json ./
RUN npm install --omit=dev --no-audit --no-fund && npm cache clean --force

COPY --from=backend-build /app/dist ./dist
COPY --from=frontend-build /app/frontend/dist ./public

EXPOSE 3001
USER node

CMD ["node", "dist/index.js"]