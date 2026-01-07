import React from 'react';
import './Header.css';
import mainImage from "../assets/undraw_software_engineer_re_tnjc.svg";

class Header extends React.Component {
    constructor(props) {
        super(props);

        this.state = {
            isEmailVisible: false,
        };
    }

    componentDidMount() {
        this.setState({
            isEmailVisible: true,
        })
    };


    render() {
        const headerTitle = (
            <h1 className="Header-main-phrase">
                Software development company
            </h1>
        );

        const mainImageBlock = (
            <div>
                <img className="Header-main-image" src={mainImage} alt="ocmoxa"></img>
            </div>
        );

        const mainPhrase = (
            <p>We are working on IT innovations.</p>
        );

        const contactInformation = (
            <p>Ho Chi Minh city, Vietnam,<span> </span>
                {this.state.isEmailVisible &&
                    <a href="mailto:contact@ocmoxa.com">contact@ocmoxa.com</a>
                }
            </p>
        );

        return (
            <header className="Header">\


                <div className="Header-main">
                    <div className="Header-main-text">
                        {headerTitle}
                        {mainPhrase}
                        {contactInformation}
                    </div>
                    {mainImageBlock}
                </div>
            </header>
        );
    }
}

export default Header;