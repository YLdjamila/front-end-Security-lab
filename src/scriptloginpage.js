import React, { useEffect } from 'react';

function ScriptLoginPage() {
    useEffect(() => {
        const container = document.getElementById('container');
        const registerBtn = document.getElementById('register');
        const loginBtn = document.getElementById('login');

        if (container && registerBtn && loginBtn) {
            registerBtn.addEventListener('click', () => {
                container.classList.add("active");
            });

            loginBtn.addEventListener('click', () => {
                container.classList.remove("active");
            });
        }
    }, []);

    return null;
}

export default ScriptLoginPage;
