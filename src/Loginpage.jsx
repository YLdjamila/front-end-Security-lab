import React, { useEffect } from 'react';
import './loginpage.css';
import ScriptLoginPage from './scriptloginpage';
import logo from './photo_2024-04-02_17-32-19.jpg';

function LoginPage() {
    useEffect(() => {
        const container = document.getElementById('container');
        const registerBtn = document.getElementById('registerBtn');
        const loginBtn = document.getElementById('loginBtn');

        if (container && registerBtn && loginBtn) {
            registerBtn.addEventListener('click', () => {
                container.classList.add("active");
            });

            loginBtn.addEventListener('click', () => {
                container.classList.remove("active");
            });
        }
    }, []);

    return (
        <div className="container" id="container">
            {/* Incluez le composant ScriptLoginPage pour gérer les événements */}
            <ScriptLoginPage />

            <div className="form-container sign-up">
                <form>
                    <h1><img src={logo} alt="Logo" /></h1>
                    <h1>Créer un compte</h1>
                    <input type="text" placeholder="Nom" />
                    <input type="email" placeholder="Email" />
                    <input type="password" placeholder="Mot de passe" />
                    <button id="registerBtn">S'inscrire</button> {/* Utilisez l'identifiant "registerBtn" */}
                </form>
            </div>
            <div className="form-container sign-in">
                <form>
                    <h1><img src={logo} alt="Logo" /></h1> {/* Utilisez l'image importée */}
                    <h1>Se connecter</h1>
                    <input type="email" placeholder="Email" />
                    <input type="password" placeholder="Mot de passe" />
                    <a href="#">Mot de passe oublié ?</a>
                    <button id="loginBtn">Se connecter</button> {/* Utilisez un nouvel identifiant unique */}
                </form>
            </div>
            <div className="toggle-container">
                <div className="toggle">
                    <div className="toggle-panel toggle-left">
                        <h1>Bienvenue! </h1>
                        <p>Inscrivez-vous avec vos informations personnelles pour accéder à toutes les fonctionnalités du site et profiter de nos services pharmaceutiques.</p>
                        <button className="hidden" id="login">Se connecter</button>
                    </div>
                    <div className="toggle-panel toggle-right">
                        <h1>Bonjour! De retour parmi nous!</h1>
                        <p>Inscrivez vos informations personnelles pour accéder à toutes les fonctionnalités du site.</p>
                        <button className="hidden" id="register">S'inscrire</button>
                    </div>
                </div>
            </div>
        </div>
    );
}
